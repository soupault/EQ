class my_subscriber extends uvm_subscriber #( my_transaction );
  
  `uvm_component_utils( my_subscriber )

  bit [31:0] pcm_data;

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new

  // coverage here or something else
  /*
  covergroup cover_bus;
    coverpoint data { bins d[16] = {[0:255]}; }
  endgroup: coverbus
  */

  function void write( my_transaction t );
    pcm_data = t.data;
    `uvm_info( "ID", "Transaction recieved", UVM_NONE )
    // last is verbosity ( _NONE, _LOW, _MEDIUM, _HIGH, _FULL )
    // can be setup '+UVM_VERBOSITY=UVM_LOW'
    
    $display( "%b", pcm_data );
    // cover_bus.sample() // store information to coverage db
  endfunction: write

endclass: my_subscriber

