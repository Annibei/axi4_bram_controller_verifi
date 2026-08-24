
class axi4_random_sequence extends axi4_base_seq;
  `uvm_object_utils(axi4_random_sequence)

  // 25,000 pairs = 50,000 total AXI transactions.
  int unsigned num_pairs = 25000;

  function new(string name = "axi4_random_sequence");
    super.new(name);
  endfunction

  virtual task body();
    axi4_item wr_item, rd_item;

    if ($value$plusargs("NUM_PAIRS=%d", num_pairs)) begin
      `uvm_info("RAND_SEQ",
        $sformatf("NUM_PAIRS plusarg detected -> running %0d pairs", num_pairs), UVM_LOW)
    end

    `uvm_info("RAND_SEQ",
      $sformatf("Starting randomized regression: %0d write+read-back pairs (%0d total transactions)",
                num_pairs, num_pairs * 2), UVM_LOW)

    for (int unsigned i = 0; i < num_pairs; i++) begin
      //Randomized WRITE
      wr_item = axi4_item::type_id::create($sformatf("wr_item_%0d", i));
      start_item(wr_item);
      if (!wr_item.randomize() with {
            trans_type == WRITE;
            addr < 32'h0000_8000;                    
            foreach (wstrb[k]) wstrb[k] == 4'b1111;   
          }) begin
        `uvm_fatal("RAND_SEQ", "Write randomization failed!")
      end
      finish_item(wr_item);

      rd_item = axi4_item::type_id::create($sformatf("rd_item_%0d", i));
      start_item(rd_item);
      if (!rd_item.randomize() with {
            trans_type == READ;
            addr  == wr_item.addr;
            len   == wr_item.len;
            burst == wr_item.burst;
            size  == wr_item.size;
          }) begin
        `uvm_fatal("RAND_SEQ", "Read randomization failed!")
      end
      finish_item(rd_item);

      if (i % 1000 == 0) begin
        `uvm_info("RAND_SEQ", $sformatf("Progress: %0d / %0d pairs issued", i, num_pairs), UVM_LOW)
      end
    end

    `uvm_info("RAND_SEQ", "Randomized regression complete.", UVM_LOW)
  endtask

endclass
