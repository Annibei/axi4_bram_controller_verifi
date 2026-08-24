class axi4_base_test extends uvm_test;
  `uvm_component_utils(axi4_base_test)


  axi4_env env;

  function new(string name = "axi4_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);


    env = axi4_env::type_id::create("env", this);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    

    uvm_top.print_topology();
  endfunction

virtual task run_phase(uvm_phase phase);
  axi4_burst_sequence seq;

  phase.raise_objection(this);
  phase.phase_done.set_drain_time(this, 100ns);
  seq = axi4_burst_sequence::type_id::create("seq");
  seq.start(env.agent.sequencer);
  phase.drop_objection(this);
endtask

endclass