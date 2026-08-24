class axi4_monitor extends uvm_monitor;
  `uvm_component_utils(axi4_monitor)

  virtual axi4_if vif;
  uvm_analysis_port #(axi4_item) ap;
  axi4_item cov_item;

  covergroup axi4_cg;
    option.per_instance = 1;

    cp_trans_type: coverpoint cov_item.trans_type {
      bins write_op = {WRITE};
      bins read_op  = {READ};  
    }

    cp_burst_type: coverpoint cov_item.burst {
      bins fixed = {FIXED}; 
      bins incr  = {INCR};  
      bins wrap  = {WRAP};
    }

    cp_len: coverpoint cov_item.len {
      bins single_beat = {0};
      bins short_burst = {[1:3]};
      bins long_burst  = {[4:15]};
    }
    cross_trans_burst_len: cross cp_trans_type, cp_burst_type, cp_len;
  endgroup

  function new(string name = "axi4_monitor", uvm_component parent = null);
    super.new(name, parent);
    axi4_cg = new();
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON_NOVIF", "Virtual interface 'vif' not set!")
    end
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("MON_COV",
      $sformatf("axi4_cg functional coverage: %0.2f%% (trans_type x burst_type x len cross)",
                axi4_cg.get_coverage()), UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);
    wait(vif.resetn == 1'b1);
    fork
      monitor_writes();
      monitor_reads();
    join
  endtask

// WRITE CHANNEL MONITORING
  virtual task monitor_writes();
    axi4_item wr_item;
    forever begin
      @(posedge vif.clk);
      
      if (vif.awvalid && vif.awready) begin
        wr_item = axi4_item#()::type_id::create("wr_item");
        wr_item.trans_type = WRITE;
        wr_item.id         = vif.awid;
        wr_item.addr       = vif.awaddr;
        wr_item.len        = vif.awlen;
        wr_item.size       = vif.awsize;           
        $cast(wr_item.burst, vif.awburst);         
        

        wr_item.data = new[wr_item.len + 1];
        for (int i = 0; i <= wr_item.len; i++) begin

          do begin
            @(posedge vif.clk);
          end while (!(vif.wvalid && vif.wready));
          wr_item.data[i] = vif.wdata;
        end
        
        // Capture Write Response Phase
        while (!(vif.bvalid && vif.bready)) begin
          @(posedge vif.clk);
        end
        $cast(wr_item.resp, vif.bresp);
        
        cov_item = wr_item;
        axi4_cg.sample();

        ap.write(wr_item);
      end
    end
  endtask

 // READ CHANNEL MONITORING
  virtual task monitor_reads();
    axi4_item rd_item;
    forever begin
      @(posedge vif.clk);
    
      // Capture Read Address Phase (AR Channel)
      if (vif.arvalid && vif.arready) begin
        rd_item = axi4_item#()::type_id::create("rd_item");
        rd_item.trans_type = READ; 
        rd_item.id         = vif.arid;
        rd_item.addr       = vif.araddr;
        rd_item.len        = vif.arlen;
        rd_item.size       = vif.arsize;           
        $cast(rd_item.burst, vif.arburst);         
        
        // Capture Read Data & Response Phase (R Channel)
        rd_item.data = new[rd_item.len + 1];
        
        for (int i = 0; i <= rd_item.len; i++) begin
          do begin
            @(posedge vif.clk);
          end while (!(vif.rvalid && vif.rready));
          
          rd_item.data[i] = vif.rdata;
          
          if (i == rd_item.len) begin
            $cast(rd_item.resp, vif.rresp);
          end
        end
        
        // Sample coverage for the read transaction
        cov_item = rd_item;
        axi4_cg.sample();

        // Broadcast the completed read item to the scoreboard
        ap.write(rd_item);
      end
    end
  endtask

endclass