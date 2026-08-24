class axi4_driver extends uvm_driver#(axi4_item);

`uvm_component_utils(axi4_driver)
  function new(string name = "axi4_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

virtual axi4_if vif;

virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(virtual axi4_if)::get(this, "", "vif", vif)) begin
    `uvm_fatal("DRIVER_NOVIF", "Didn't get handle to virtual interface axi4_if")
  end
endfunction

virtual task run_phase(uvm_phase phase);
  axi4_item tr;
  

  reset_signals();
  wait(vif.resetn == 1'b1);

  forever begin 
    seq_item_port.get_next_item(tr);

    if (tr.trans_type == WRITE) begin
      drive_write(tr);
    end else if (tr.trans_type == READ) begin
      drive_read(tr);
    end else begin
      `uvm_error("DRV_ERR", "Unknown transaction type received!")
    end

    seq_item_port.item_done();
  end
endtask

// INITALIZATION
virtual task reset_signals();
    vif.awvalid <= 1'b0;
    vif.wvalid  <= 1'b0;
    vif.bready  <= 1'b0;
    vif.arvalid <= 1'b0;
    vif.rready  <= 1'b0;
    

    vif.awlock  <= 1'b0;
    vif.awcache <= 4'b0000;
    vif.awprot  <= 3'b000;
    vif.arlock  <= 1'b0;
    vif.arcache <= 4'b0000;
    vif.arprot  <= 3'b000;
  endtask

// Write Transactions
  virtual task drive_write(axi4_item item);
    @(posedge vif.clk);
    vif.awid    <= item.id;
    vif.awaddr  <= item.addr;
    vif.awlen   <= item.len;
    vif.awsize  <= item.size;
    vif.awburst <= item.burst;
    vif.awvalid <= 1'b1;

    wait(vif.awready == 1'b1);
    @(posedge vif.clk);
    vif.awvalid <= 1'b0;

    // Write Data (W)
    for (int i = 0; i <= item.len; i++) begin
      vif.wdata <= item.data[i];
      vif.wstrb <= (item.wstrb.size() > i && item.wstrb[i] != 4'b0000) ? item.wstrb[i] : 4'b1111;
      vif.wlast <= (i == item.len) ? 1'b1 : 1'b0;
      vif.wvalid <= 1'b1;

      wait(vif.wready == 1'b1);
      @(posedge vif.clk);
    end
    vif.wvalid <= 1'b0;
    vif.wlast  <= 1'b0;

    // Write Response (B) 
    vif.bready <= 1'b1;
    wait(vif.bvalid == 1'b1);
    
    $cast(item.resp, vif.bresp); 
    
    @(posedge vif.clk);
    vif.bready <= 1'b0;
  endtask

  // READ TRANSACTION
virtual task drive_read(axi4_item item);
    @(posedge vif.clk);
    vif.arid    <= item.id;
    vif.araddr  <= item.addr;
    vif.arlen   <= item.len;
    vif.arsize  <= item.size;
    vif.arburst <= item.burst;
    vif.arvalid <= 1'b1;

    wait(vif.arready == 1'b1);
    @(posedge vif.clk);
    vif.arvalid <= 1'b0;

    // Read Data (R)
    item.data = new[item.len + 1];
    
    vif.rready <= 1'b1;
    for (int i = 0; i <= item.len; i++) begin
      wait(vif.rvalid == 1'b1);
      
      item.data[i] = vif.rdata;
      $cast(item.resp, vif.rresp); 
      
      @(posedge vif.clk);
      
      if (vif.rlast == 1'b1) break; 
    end
    vif.rready <= 1'b0;
  endtask

endclass