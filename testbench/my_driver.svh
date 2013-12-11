class my_driver extends uvm_driver #( my_transaction );
  
  `uvm_component_utils( my_driver )
  
  virtual dut_if dut_vi;
  my_dut_config x_config;

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new

  function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    if( !uvm_config_db #( my_dut_config )::get( this, "", "dut_config", x_config ) )
      `uvm_fatal( "MY_TEST", "Driver can't get DUT_IF")
  endfunction: build_phase
  
  function void connect_phase( uvm_phase phase );
    super.connect_phase( phase );
    dut_vi = x_config.dut_vi;
  endfunction: connect_phase
  
  task run_phase( uvm_phase phase );

    forever 
      begin
        my_transaction tx;
        @( posedge dut_vi.clk2 );
        seq_item_port.get_next_item( tx );
        
        dut_vi.spdif = tx.data;

        // @( posedge dut_vi.clk2 ); // TODO: check it
        seq_item_port.item_done(); 
      end
  endtask: run_phase

endclass: my_driver

