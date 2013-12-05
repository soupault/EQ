typedef uvm_sequencer #( my_transaction ) my_sequencer;

// We don't actually need advanced sequencer
// using vanilla by default
/*
class my_sequencer extends uvm_sequencer #( my_transaction );
  `uvm_component_utils( my_sequencer );

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new

endclass: my_sequencer
*/

