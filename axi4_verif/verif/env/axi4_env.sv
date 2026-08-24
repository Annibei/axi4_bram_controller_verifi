class axi4_env extends uvm_env;
  `uvm_component_utils(axi4_env)

  axi4_agent      agent;
  axi4_scoreboard scoreboard;

  function new(string name = "axi4_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent      = axi4_agent::type_id::create("agent", this);
    scoreboard = axi4_scoreboard::type_id::create("scoreboard", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    agent.ap.connect(scoreboard.item_export);
  endfunction

endclass