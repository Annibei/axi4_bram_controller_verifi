`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

// Include your package containing axi4_item and enums
import axi4_agent_pkg::*; 

module tb_axi4_item;


  axi4_item item1;
  axi4_item item2;

  initial begin
    // 1. Instantiation
    item1 = axi4_item#()::type_id::create("item1");
    item2 = axi4_item#()::type_id::create("item2");

    // 2. Randomize item1 with defined array sizes
    if (!item1.randomize() with {
      data.size()  == 4;
      wstrb.size() == 4;
    }) begin
      `uvm_fatal("TB", "Randomization failed for item1!")
    end

    // Manually assign non-randomized field
    item1.resp = OKAY;

    $display("\n==================================================");
    $display("       1. TESTING convert2string()                ");
    $display("==================================================");
    $display("Output: %s", item1.convert2string());

    $display("\n==================================================");
    $display("       2. TESTING do_print() / print()            ");
    $display("==================================================");
    // Calling print() automatically invokes your custom do_print() method
    item1.print();

    $display("\n==================================================");
    $display("       3. TESTING do_copy() / copy()              ");
    $display("==================================================");
    // Calling copy() automatically invokes your custom do_copy() method
    item2.copy(item1);

    $display("Copied Item (item2) Contents:");
    item2.print();

    // Verify copy accuracy using do_compare
    if (item1.do_compare(item2, null)) begin
      `uvm_info("TB_PASS", "--- COPY SUCCESSFUL: item2 matches item1 perfectly! ---", UVM_LOW)
    end else begin
      `uvm_error("TB_FAIL", "--- COPY FAILED: item2 does not match item1! ---")
    end

    $finish;
  end

endmodule