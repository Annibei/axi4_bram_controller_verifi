module tb_compare;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  // Pulls in your sequence item code
  `include "axi4_item.sv"

  initial begin
    // 1. Declare handles using your parameters
    axi4_item #(32, 32, 4) item_a;
    axi4_item #(32, 32, 4) item_b;

    // 2. Create the objects using the UVM factory
    item_a = axi4_item#(32, 32, 4)::type_id::create("item_a");
    item_b = axi4_item#(32, 32, 4)::type_id::create("item_b");

    // ==========================================
    // TEST 1: The "Happy Path" (Exact Match)
    // ==========================================
    $display("\n--- TEST 1: Identical Items ---");
    item_a.addr = 32'h1000;
    item_a.len  = 8'h03;
    item_a.data = new[4]; // Allocate 4 bytes
    item_a.data = '{8'hAA, 8'hBB, 8'hCC, 8'hDD}; // Assign payload

    item_b.addr = 32'h1000;
    item_b.len  = 8'h03;
    item_b.data = new[4]; 
    item_b.data = '{8'hAA, 8'hBB, 8'hCC, 8'hDD};

    // UVM's compare() calls your do_compare() behind the scenes
    if (item_a.compare(item_b)) begin
      $display("PASS: Items matched correctly!");
    end else begin
      $display("FAIL: Items should have matched but didn't.");
    end

    // ==========================================
    // TEST 2: Scalar Mismatch (Different Address)
    // ==========================================
    $display("\n--- TEST 2: Address Mismatch ---");
    item_b.addr = 32'h2000; // Corrupt the target address

    if (!item_a.compare(item_b)) begin
      $display("PASS: compare() successfully caught the mismatched address.");
    end else begin
      $display("FAIL: compare() returned 1 even though addresses were different!");
    end

    // ==========================================
    // TEST 3: Array Size Mismatch
    // ==========================================
    $display("\n--- TEST 3: Array Size Mismatch ---");
    item_b.addr = 32'h1000; // Fix the address back to normal
    
    // Resize item_b's array to be smaller than item_a's
    item_b.data = new[2]; 
    item_b.data = '{8'hAA, 8'hBB};

    // This will trigger the array size logic you wrote
    if (!item_a.compare(item_b)) begin
      $display("PASS: compare() successfully caught the array size difference.");
    end else begin
      $display("FAIL: compare() returned 1 despite different array sizes!");
    end

    $display("\nTesting Complete.\n");
    $finish;
  end
endmodule