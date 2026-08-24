module tb_axi4_item_test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Include your item class definition directly
  `include "axi4_item.sv"

  initial begin
    // 1. Instantiation
    axi4_item #(32, 32, 4) item1;
    axi4_item #(32, 32, 4) item2;

    item1 = axi4_item#(32, 32, 4)::type_id::create("item1");
    item2 = axi4_item#(32, 32, 4)::type_id::create("item2");

    // 2. Test Randomization and convert2string()
    `uvm_info("UNIT_TEST", "--- Testing Randomization ---", UVM_LOW)
    repeat (3) begin
      if (!item1.randomize()) begin
        `uvm_error("UNIT_TEST", "Randomization failed!")
      end else begin
        `uvm_info("UNIT_TEST", $sformatf("Randomized Item: %s", item1.convert2string()), UVM_LOW)
      end
    end

    // 3. Test do_copy()
    `uvm_info("UNIT_TEST", "--- Testing do_copy ---", UVM_LOW)
    item2.copy(item1); // Triggers do_copy behind the scenes
    `uvm_info("UNIT_TEST", $sformatf("Item 1 (Original): %s", item1.convert2string()), UVM_LOW)
    `uvm_info("UNIT_TEST", $sformatf("Item 2 (Copied)  : %s", item2.convert2string()), UVM_LOW)

    // 4. Test do_compare() - Pass Case
    `uvm_info("UNIT_TEST", "--- Testing do_compare (Expected Match) ---", UVM_LOW)
    if (item1.compare(item2)) begin // Triggers do_compare behind the scenes
      `uvm_info("UNIT_TEST", "PASS: item1 and item2 are identical.", UVM_LOW)
    end else begin
      `uvm_error("UNIT_TEST", "FAIL: item1 and item2 do not match!")
    end

    // 5. Test do_compare() - Fail Case
    `uvm_info("UNIT_TEST", "--- Testing do_compare (Expected Mismatch) ---", UVM_LOW)
    item2.addr = item1.addr + 32'h04; // Corrupt field
    if (!item1.compare(item2)) begin
      `uvm_info("UNIT_TEST", "PASS: Mismatch successfully detected.", UVM_LOW)
    end else begin
      `uvm_error("UNIT_TEST", "FAIL: compare() reported match despite corrupt address!")
    end

    $finish;
  end
endmodule