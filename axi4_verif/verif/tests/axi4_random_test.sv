class axi4_random_test extends axi4_base_test;
  `uvm_component_utils(axi4_random_test)

  function new(string name = "axi4_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    axi4_random_sequence seq;

    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this, 100ns);

    seq = axi4_random_sequence::type_id::create("seq");
    seq.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask

endclass
