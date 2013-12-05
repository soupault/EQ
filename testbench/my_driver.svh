class my_driver extends uvm_driver #( my_transaction );
  
  `uvm_component_utils( my_driver )
  virtual dut_if dut_vi;

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new

  function void build_phase( uvm_phase phase );
    super.build_phase( phase );
  endfunction: build_phase
  
  task run_phase( uvm_phase phase );

    forever 
      begin
        my_transaction tx;
        @( posedge dut_vi.clk );
        seq_item_port.get_next_item( tx );
        // TODO:
        // dut_vi.data = tx.data;
        // and so on
        @( posedge dut_vi.clk );
        seq_item_port.item_done(); 
      end
  endtask: run_phase

endclass: my_driver

