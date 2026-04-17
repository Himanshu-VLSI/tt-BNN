# ============================================================
# TinyTapeout Project Information File
# ============================================================

project:
  name: "Binary Neural Network Inference Engine"
  author: "Your Name"
  description: >
    A fully combinational Binary Neural Network (BNN) inference engine.
    The design uses XNOR operations for multiplication and popcount for accumulation,
    enabling efficient neural network computation without multipliers.
    It classifies a 6-bit input vector into two output classes using a 2-layer architecture.

  language: "Verilog"
  clock_hz: 0

  # TinyTapeout uses 8 inputs and 8 outputs
  tiles: "1x1"

  top_module: "bnn_top"

  source_files:
    - "bnn_top.v"
    - "bnn_neuron6.v"
    - "bnn_neuron4.v"
    - "popcount4.v"

# ============================================================
# Pin Configuration
# ============================================================

pinout:
  ui[0]: "Input feature bit 0"
  ui[1]: "Input feature bit 1"
  ui[2]: "Input feature bit 2"
  ui[3]: "Input feature bit 3"
  ui[4]: "Input feature bit 4"
  ui[5]: "Input feature bit 5"
  ui[6]: "Unused"
  ui[7]: "Unused"

  uo[0]: "Class 0 output"
  uo[1]: "Class 1 output"
  uo[2]: "Confidence bit (class 0 LSB)"
  uo[3]: "Confidence bit (class 1 LSB)"
  uo[4]: "Hidden neuron 0"
  uo[5]: "Hidden neuron 1"
  uo[6]: "Hidden neuron 2"
  uo[7]: "Hidden neuron 3"



documentation:
  how_it_works: >
    The design implements a Binary Neural Network (BNN) using combinational logic.
    Each neuron performs an XNOR operation between input and weights, followed by
    a popcount to count matching bits. The result is compared against a threshold
    to produce a binary output. Two layers are used: a hidden layer with 4 neurons
    and an output layer with 2 neurons.

  inputs: >
    A 6-bit binary input vector representing features.
    Each bit corresponds to +1 or -1 in binary form.

  outputs: >
    Two output bits represent classification results.
    Additional bits expose internal hidden neuron outputs and confidence levels.

  limitations: >
    The weights are fixed at synthesis time and not programmable.
    This is a small demonstration model and not suitable for large-scale inference.

  extras: >
    Designed for TinyTapeout with a focus on minimal area and purely combinational logic.
    
