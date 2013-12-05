class my_sequence extends uvm_sequence #( my_transaction );

  `uvm_object_utils( my_sequence );

  function new( string name = "" );
    super.new( name );
  endfunction: new

  task body;
    // FIXME: or put finite amounts
    forever
      begin
        my_transaction tx;
        tx = my_transaction::type_id::create( "tx" );
        // Communicating the driver
        start_item( tx );
        // Modify randomization due to current state of system if needed
        assert( tx.randomize() );
        finish_item( tx );
      end
  endtask: body

endclass: my_sequence

