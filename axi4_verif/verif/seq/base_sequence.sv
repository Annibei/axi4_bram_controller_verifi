class axi4_base_seq extends uvm_sequence #(axi4_item);
  `uvm_object_utils(axi4_base_seq)

  function new(string name = "axi4_base_seq");
    super.new(name);
  endfunction

  virtual task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this, get_type_name());
    end
  endtask

  virtual task post_body();
    if (starting_phase != null) begin
      starting_phase.drop_objection(this, get_type_name());
    end
  endtask


  // HELPER TASKS
virtual task write_data(
    input bit [31:0] addr,
    input bit [31:0] data[],
    input bit [3:0]  id    = 0,
    input bit [1:0]  burst = 1,
    input bit [2:0]  size  = 2
  );
    axi4_item item = axi4_item::type_id::create("write_item");
    int computed_len = data.size() - 1;

    start_item(item);
    if (!item.randomize() with {
      trans_type == WRITE;
      addr       == local::addr;
      id         == local::id;
      burst      == local::burst;
      len        == local::computed_len;
      size       == local::size;
      foreach (wstrb[k]) wstrb[k] == 4'b1111; 
    }) begin
      `uvm_fatal("SEQ_RAND_FAIL", "Randomization failed for write transaction!")
    end

    item.data = data;
    finish_item(item);
  endtask

  virtual task read_data(
    input bit [31:0] addr,
    input int        len   = 0,
    input bit [3:0]  id    = 0,
    input bit [1:0]  burst = 1,
    input bit [2:0]  size  = 2 
  );
    axi4_item item = axi4_item::type_id::create("read_item");

    start_item(item);
    if (!item.randomize() with {
      trans_type == READ;
      addr       == local::addr;
      id         == local::id;
      burst      == local::burst;
      len        == local::len;
      size       == local::size; 
    }) begin
      `uvm_fatal("SEQ_RAND_FAIL", "Randomization failed for read transaction!")
    end
    finish_item(item);
  endtask

endclass