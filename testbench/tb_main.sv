`timescale 1ns / 1ns

`include "pkg.sv"
`include "../top.sv"
`include "dut_if.sv"

module tb_main;

  import uvm_pkg::*;
  import my_pkg::*;

  dut_if  dut_iface(); 
  
  top     dut_top( .main_if( dut_iface ) );
 
  initial
    begin
      $display( "All is over!" );
      // Passing dut_if to config database
      uvm_config_db #( virtual dut_if )::set( null, "uvm_test_top",
                                              "dut_vi", dut_iface );
      run_test( "my_test" ); // can be defined with 'vsim +UVM_TESTNAME=my_test'
    end

endmodule

