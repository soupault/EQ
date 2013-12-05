class my_transaction extends uvm_sequence_item;

  `uvm_object_utils( my_transaction )

  // TODO: various signals
  rand int data;
  // rand bit something

  // constraint c_data { data <= 900; data > 5 }

  function new( string name = "" );
    super.new( name );
  endfunction: new

endclass: my_transaction

