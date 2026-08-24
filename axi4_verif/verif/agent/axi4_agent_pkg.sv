package axi4_agent_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum bit {
  READ  = 1'b0,
  WRITE = 1'b1
} axi_trans_e;

// AXI4 Burst Types
  typedef enum bit [1:0] {
    FIXED = 2'b00,
    INCR  = 2'b01,
    WRAP  = 2'b10
  } axi_burst_e;

  // AXI4 Response Types
  typedef enum bit [1:0] {
    OKAY   = 2'b00,
    EXOKAY = 2'b01,
    SLVERR = 2'b10,
    DECERR = 2'b11
  } axi_resp_e;

`include "axi4_item.sv"
`include "axi4_driver.sv"
`include "axi4_monitor.sv"
`include "axi4_sequencer.sv"
`include "axi4_agent.sv"
endpackage