`timescale 1ns / 1ns

`include "pkg.sv"
`include "../top.sv"
`include "dut_if.sv"

module tb_main;

  import uvm_pkg::*;
  import my_pkg::*;

  dut_if  dut_iface();
 
  default clocking clock @( posedge dut_iface.clk6 );
  endclocking

  initial
    begin
      dut_iface.clk6 = 0;
      forever
        #1.0 dut_iface.clk6 = ~dut_iface.clk6;
    end

  initial
    begin
      dut_iface.clk2 = 0;
      forever
        #3.0 dut_iface.clk2 = ~dut_iface.clk2;
    end
  
  initial
    begin
      dut_iface.clk = 0;
      forever
        #6.0 dut_iface.clk = ~dut_iface.clk;
    end

  initial
    begin
      dut_iface.nrst = 0;
      ##1;
      dut_iface.nrst = 1;
    end

  top dut_top(
    .main_if( dut_iface )
  );

  initial
    begin
      $display( "*** Global start ***" );
      // Passing dut_if to config database
      uvm_config_db #( virtual dut_if )::set( null, "uvm_test_top",
                                              "dut_vi", dut_iface );
      run_test( "my_test" ); // can be defined with 'vsim +UVM_TESTNAME=my_test'
    end

endmodule

