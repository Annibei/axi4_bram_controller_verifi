package axi4_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import axi4_agent_pkg::*;

  `include "base_sequence.sv"
  `include "axi4_burst_sequence.sv"
  `include "axi4_random_sequence.sv"

endpackage