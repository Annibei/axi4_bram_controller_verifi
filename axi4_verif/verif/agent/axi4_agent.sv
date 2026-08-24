class axi4_agent extends uvm_agent;
  `uvm_component_utils(axi4_agent)

  axi4_driver    driver;
  axi4_sequencer sequencer;
  axi4_monitor   monitor;

//enviornment/scoreboard
  uvm_analysis_port #(axi4_item) ap;

  function new(string name = "axi4_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Analysis and Scoreboard Ports
    monitor = axi4_monitor::type_id::create("monitor", this);
    ap      = new("ap", this);

    // Conditional Driver and Sequencer
    if (get_is_active() == UVM_ACTIVE) begin
      driver    = axi4_driver::type_id::create("driver", this);
      sequencer = axi4_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    monitor.ap.connect(this.ap);

    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction

endclass