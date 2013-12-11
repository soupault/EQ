class my_transaction extends uvm_sequence_item;

  `uvm_object_utils( my_transaction )

  rand bit data; 

  function new( string name = "" );
    super.new( name );
  endfunction: new

endclass: my_transaction

