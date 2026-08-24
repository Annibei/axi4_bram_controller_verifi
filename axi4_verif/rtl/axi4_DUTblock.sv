module axi4_DUTblock;
  logic clk = 0;
  logic resetn = 0;
  
  // Instantiate Interface
  axi4_if vif(clk, resetn);
  
  // Instantiate the PG078 DUT 
  axi_bram_ctrl_0 my_bram_dut (
    .s_axi_aclk    (clk),
    .s_axi_aresetn (resetn),
    
    // WRITE ADDRESS CHANNEL (AW) 
    .s_axi_awid    (vif.awid[0]),       
    .s_axi_awaddr  (vif.awaddr[14:0]), 
    .s_axi_awlen   (vif.awlen),
    .s_axi_awsize  (vif.awsize),
    .s_axi_awburst (vif.awburst),
    .s_axi_awlock  (vif.awlock),
    .s_axi_awcache (vif.awcache),
    .s_axi_awprot  (vif.awprot),
    .s_axi_awvalid (vif.awvalid),
    .s_axi_awready (vif.awready),

    // WRITE DATA CHANNEL (W) 
    .s_axi_wdata   (vif.wdata),
    .s_axi_wstrb   (vif.wstrb),
    .s_axi_wlast   (vif.wlast),
    .s_axi_wvalid  (vif.wvalid),
    .s_axi_wready  (vif.wready),

    // WRITE RESPONSE CHANNEL (B) 
    .s_axi_bid     (vif.bid[0]),       
    .s_axi_bresp   (vif.bresp),
    .s_axi_bvalid  (vif.bvalid),
    .s_axi_bready  (vif.bready),

    // READ ADDRESS CHANNEL (AR) 
    .s_axi_arid    (vif.arid[0]),      
    .s_axi_araddr  (vif.araddr[14:0]),  
    .s_axi_arlen   (vif.arlen),
    .s_axi_arsize  (vif.arsize),
    .s_axi_arburst (vif.arburst),
    .s_axi_arlock  (vif.arlock),
    .s_axi_arcache (vif.arcache),
    .s_axi_arprot  (vif.arprot),
    .s_axi_arvalid (vif.arvalid),
    .s_axi_arready (vif.arready),

    // READ DATA CHANNEL (R) 
    .s_axi_rid     (vif.rid[0]),      
    .s_axi_rdata   (vif.rdata),
    .s_axi_rresp   (vif.rresp),
    .s_axi_rlast   (vif.rlast),
    .s_axi_rvalid  (vif.rvalid),
    .s_axi_rready  (vif.rready)
  );

  assign vif.bid[3:1] = '0;
  assign vif.rid[3:1] = '0;

endmodule