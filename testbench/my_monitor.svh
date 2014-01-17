class my_monitor extends uvm_monitor;
  
  `uvm_component_utils( my_monitor )
  uvm_analysis_port #( my_transaction ) aport;

  virtual dut_if dut_vi;
  my_dut_config x_config;

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new

  function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    aport = new( "aport", this );
    if( !uvm_config_db #( my_dut_config )::get( this, "", "dut_config", x_config ) )
      `uvm_fatal( "MY_TEST", "Monitor can't get DUT_IF")
  endfunction: build_phase
  
  function void connect_phase( uvm_phase phase );
    super.connect_phase( phase );
    dut_vi = x_config.dut_vi;
  endfunction: connect_phase

  task run_phase( uvm_phase phase );
    forever 
      begin
        my_transaction tx;
        tx = my_transaction::type_id::create( "tx" );
        @( posedge dut_vi.clk );
        if( dut_vi.pcm_ena )
          begin
            tx.data = dut_vi.pcm;
            // Sends tx through analysis port
            aport.write( tx );
          end
      end
  endtask: run_phase

endclass: my_monitor

