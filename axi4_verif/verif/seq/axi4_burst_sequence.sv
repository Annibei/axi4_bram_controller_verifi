class axi4_burst_sequence extends axi4_base_seq;
  `uvm_object_utils(axi4_burst_sequence)
 
  function new(string name = "axi4_burst_sequence");
    super.new(name);
  endfunction
 
 virtual task body();
  bit [31:0] wr_payload[];
 
  `uvm_info("BURST_SEQ", "Starting AXI4 Burst Write & Read Sequence...", UVM_LOW)
 

  wr_payload = new[4];
  wr_payload[0] = 32'hA1B2_C3D4;
  wr_payload[1] = 32'h5678_90AB;
  wr_payload[2] = 32'hDEAD_BEEF;
  wr_payload[3] = 32'hCAFE_BABE;
 

  `uvm_info("BURST_SEQ", "Sending 4-beat Write Burst to Address 0x1000", UVM_LOW)
  write_data(
    .addr(32'h0000_1000), 
    .data(wr_payload), 
    .id(4'h1), 
    .burst(2'b01), 
    .size(2)       
  );
 

  `uvm_info("BURST_SEQ", "Sending 4-beat Read Burst from Address 0x1000", UVM_LOW)
  read_data(
    .addr(32'h0000_1000), 
    .len(3), 
    .id(4'h1), 
    .burst(2'b01), 
    .size(2)       
  );
 
  `uvm_info("BURST_SEQ", "Burst Sequence execution complete.", UVM_LOW)
endtask
 
endclass