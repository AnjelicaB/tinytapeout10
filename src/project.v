/*
 * Copyright (c) 2024 Anjelica Bian
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_AnjelicaB_Top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  wire [7:0] in = ui_in;
  wire [7:0] out = uo_out;

  // Instantiate the design
  dev_by_five dev_by_five_inst (
    .in(in[0]),
    .out(out[0]),
    .clk(clk),
    .rst_n(rst_n)
  );

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, in[7:1], out[7:1], uio_in, uio_out, uio_oe, 1'b0};

endmodule

module dev_by_five (
  input  wire       in,
  output reg        out,
  input  wire       clk,  
  input  wire       rst_n 
);
  reg        [2:0] state;
  reg        [2:0] next_state;
  localparam [2:0] mod0 = 3'b000;
  localparam [2:0] mod1 = 3'b001;
  localparam [2:0] mod2 = 3'b010;
  localparam [2:0] mod3 = 3'b011;
  localparam [2:0] mod4 = 3'b100;
  localparam [2:0] init = 3'b101;

  // Next state logic
  always @(*) begin
    case (state)
      init: begin
        if (in == 0) begin
          next_state = mod0;
        end else begin
          next_state = mod1;
        end
      end
      mod0: begin
        if (in == 0) begin
          next_state = mod0;
        end else begin
          next_state = mod1;
        end
      end
      mod1: begin
        if (in == 0) begin
          next_state = mod2;
        end else begin
          next_state = mod3;
        end
      end
      mod2: begin
        if (in == 0) begin
          next_state = mod4;
        end else begin
          next_state = mod0;
        end
      end
      mod3: begin
        if (in == 0) begin
          next_state = mod1;
        end else begin
          next_state = mod2;
        end
      end
      mod4: begin
        if (in == 0) begin
          next_state = mod3;
        end else begin
          next_state = mod4;
        end
      end
      default: next_state = state;
    endcase
  end

  // output logic
  always @(*) begin
    case (state)
      init: out = 0;
      mod0: out = 1;
      mod1: out = 0;
      mod2: out = 0;
      mod3: out = 0;
      mod4: out = 0;
      default: out = 0;
    endcase
  end

  // State transition logic
  always @(posedge clk) begin
    if (~rst_n) begin
      state <= init;
    end else begin
      state <= next_state;
    end
  end

endmodule