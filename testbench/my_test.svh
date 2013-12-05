class my_test extends uvm_test;

  `uvm_component_utils( my_test )

  my_env my_env_h;
  my_dut_config dut_config;

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new

  function void build_phase( uvm_phase phase );
    dut_config = new();
    if( !uvm_config_db #( virtual dut_if )::get( this, "", "dut_vi", dut_config.dut_vi ) )
      `uvm_fatal( "MY_TEST", "No DUT_IF")
    // other settings
    uvm_config_db #( my_dut_config )::set( this, "*", "dut_config", dut_config );
    my_env_h = my_env::type_id::create( "my_env_h", this );
  endfunction: build_phase
  
  task run_phase( uvm_phase phase );
    my_sequence seq;
    seq = my_sequence::type_id::create( "seq" );
    phase.raise_objection( this );
    seq.start( my_env_h.my_agent_h.my_sequencer_h );
    phase.drop_objection( this );
  endtask: run_phase

endclass: my_test

