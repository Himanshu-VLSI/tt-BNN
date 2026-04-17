/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 

`default_nettype none

module tt_um_example (
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

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule*/
// Code your design here
// ============================================================
// 4-bit Popcount Module
// Counts number of 1s in input
// ============================================================

module popcount4 (
    input  [3:0] in,
    output [2:0] count
);

    // Simple combinational addition
    assign count = in[0] +
                   in[1] +
                   in[2] +
                   in[3];

endmodule
// ============================================================
// 4-bit BNN neuron (used in output layer)
// Threshold = 2
// ============================================================

module bnn_neuron4 (
    input  [3:0] x,
    input  [3:0] w,
    output out
);

    // XNOR operation
    wire [3:0] xnor_out;
    assign xnor_out = ~(x ^ w);

    // Popcount
    wire [2:0] count;

    assign count = xnor_out[0] +
                   xnor_out[1] +
                   xnor_out[2] +
                   xnor_out[3];

    // Threshold decision
    assign out = (count >= 2);

endmodule
// ============================================================
// 6-bit BNN neuron
// Performs:
//   1. XNOR between input and weights
//   2. Count number of matches (popcount)
//   3. Apply threshold (>=3)
// ============================================================

module bnn_neuron6 (
    input  [5:0] x,   // input vector
    input  [5:0] w,   // weight vector
    output out        // neuron output (1-bit)
);

    // --------------------------------------------------------
    // Step 1: XNOR → replaces multiplication
    // If bits match → 1 (+1)
    // If bits differ → 0 (-1)
    // --------------------------------------------------------
    wire [5:0] xnor_out;
    assign xnor_out = ~(x ^ w);

    // --------------------------------------------------------
    // Step 2: Popcount (count number of 1s)
    // Each '1' means +1 contribution
    // --------------------------------------------------------
    wire [2:0] count;

    assign count = xnor_out[0] +
                   xnor_out[1] +
                   xnor_out[2] +
                   xnor_out[3] +
                   xnor_out[4] +
                   xnor_out[5];

    // --------------------------------------------------------
    // Step 3: Threshold activation
    // If matches ≥ 3 → output = 1
    // Else → output = 0
    // --------------------------------------------------------
    assign out = (count >= 3);

endmodule
// ============================================================
// TinyTapeout Binary Neural Network (BNN)
// 6-bit input → 4 hidden neurons → 2 output classes
// Fully combinational (no clock, no sequential logic)
// ============================================================

module bnn_top (
    input  [5:0] ui_in,        // 6-bit input feature vector
    output [7:0] uo_out        // 8-bit output bus
);

    // --------------------------------------------------------
    // Hidden layer outputs (1-bit each neuron)
    // --------------------------------------------------------
    wire h0, h1, h2, h3;

    // --------------------------------------------------------
    // Layer 1 Weights (Fixed)
    // Each weight bit:
    //   1 → +1
    //   0 → -1
    // --------------------------------------------------------
    wire [5:0] W1_0 = 6'b101011;
    wire [5:0] W1_1 = 6'b110001;
    wire [5:0] W1_2 = 6'b011010;
    wire [5:0] W1_3 = 6'b111100;

    // --------------------------------------------------------
    // Hidden Layer Computation
    // Each neuron performs:
    //   XNOR → popcount → threshold
    // --------------------------------------------------------
    bnn_neuron6 H0 (.x(ui_in), .w(W1_0), .out(h0));
    bnn_neuron6 H1 (.x(ui_in), .w(W1_1), .out(h1));
    bnn_neuron6 H2 (.x(ui_in), .w(W1_2), .out(h2));
    bnn_neuron6 H3 (.x(ui_in), .w(W1_3), .out(h3));

    // Combine hidden neuron outputs into a 4-bit vector
    wire [3:0] hidden = {h3, h2, h1, h0};

    // --------------------------------------------------------
    // Layer 2 Weights (Output Layer)
    // --------------------------------------------------------
    wire [3:0] W2_0 = 4'b1011;
    wire [3:0] W2_1 = 4'b0110;

    // Output neurons
    wire o0, o1;

    bnn_neuron4 O0 (.x(hidden), .w(W2_0), .out(o0));
    bnn_neuron4 O1 (.x(hidden), .w(W2_1), .out(o1));

    // --------------------------------------------------------
    // Confidence Calculation (based on popcount)
    // --------------------------------------------------------
    wire [2:0] pop_o0;
    wire [2:0] pop_o1;

    // Recompute XNOR + popcount for confidence
    popcount4 PC0 (.in(~(hidden ^ W2_0)), .count(pop_o0));
    popcount4 PC1 (.in(~(hidden ^ W2_1)), .count(pop_o1));

    // --------------------------------------------------------
    // Output Mapping (TinyTapeout format)
    // --------------------------------------------------------
    // uo_out[1:0] → class outputs
    assign uo_out[0] = o0;   // class 0
    assign uo_out[1] = o1;   // class 1

    // uo_out[3:2] → confidence (LSB bits)
    assign uo_out[2] = pop_o0[0];
    assign uo_out[3] = pop_o1[0];

    // uo_out[7:4] → hidden layer outputs (for debug/visibility)
    assign uo_out[7:4] = hidden;

endmodule
