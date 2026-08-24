interface axi4_if #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int ID_WIDTH   = 4
) (
  input logic clk,
  input logic resetn
);

  // WRITE ADDRESS CHANNEL (AW)
  logic [ID_WIDTH-1:0]   awid;
  logic [ADDR_WIDTH-1:0] awaddr;
  logic [7:0]            awlen;
  logic [2:0]            awsize;
  logic [1:0]            awburst;
  logic                  awlock;
  logic [3:0]            awcache;
  logic [2:0]            awprot;
  logic                  awvalid;
  logic                  awready;

  // WRITE DATA CHANNEL (W)
  logic [DATA_WIDTH-1:0]     wdata;
  logic [(DATA_WIDTH/8)-1:0] wstrb;
  logic                      wlast;
  logic                      wvalid;
  logic                      wready;

  // WRITE RESPONSE CHANNEL (B)
  logic [ID_WIDTH-1:0]   bid;
  logic [1:0]            bresp;
  logic                  bvalid;
  logic                  bready;

  // READ ADDRESS CHANNEL (AR)
  logic [ID_WIDTH-1:0]   arid;
  logic [ADDR_WIDTH-1:0] araddr;
  logic [7:0]            arlen;
  logic [2:0]            arsize;
  logic [1:0]            arburst;
  logic                  arlock;
  logic [3:0]            arcache;
  logic [2:0]            arprot;
  logic                  arvalid;
  logic                  arready;

  // READ DATA CHANNEL (R)
  logic [ID_WIDTH-1:0]   rid;
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rlast;
  logic                  rvalid;
  logic                  rready;


  // SYSTEMVERILOG ASSERTIONS (SVA)
  
  // Rule 1: AWVALID must remain HIGH until AWREADY is asserted
  property p_awvalid_stable;
    @(posedge clk) disable iff (!resetn)
    awvalid && !awready |=> $stable(awvalid) && $stable(awaddr) && $stable(awid);
  endproperty
  assert_awvalid_stable: assert property (p_awvalid_stable)
    else $error("[SVA ERROR] AWVALID or payload changed before AWREADY handshake!");

  // Rule 2: Deadlock Detection - AWREADY must respond within 100 clock cycles
  property p_aw_deadlock;
    @(posedge clk) disable iff (!resetn)
    awvalid && !awready |-> ##[1:100] awready;
  endproperty
  assert_aw_deadlock: assert property (p_aw_deadlock)
    else $error("[SVA DEADLOCK] AWREADY failed to assert within 100 clock cycles!");

  // Rule 3: WVALID must remain HIGH until WREADY is asserted
  property p_wvalid_stable;
    @(posedge clk) disable iff (!resetn)
    wvalid && !wready |=> $stable(wvalid) && $stable(wdata);
  endproperty
  assert_wvalid_stable: assert property (p_wvalid_stable)
    else $error("[SVA ERROR] WVALID or WDATA changed before WREADY handshake!");
endinterface