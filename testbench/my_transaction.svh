class my_transaction extends uvm_sequence_item;

  `uvm_object_utils( my_transaction )

  bit [31:0] data; 

  function new( string name = "" );
    super.new( name );
  endfunction: new

endclass: my_transaction

