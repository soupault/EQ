`include "edge_detector.sv"
`include "testbench/dut_if.sv"

module top
(
  dut_if  main_if
);

edge_detector edge_detector
(
  .spdif_i  ( main_if.spdif ),
  .clk_i    ( main_if.clk   ),
  .nrst_i   ( main_if.nrst  ),

  .zero_o   (               ),
  .one_o    (               ),
  .head_o   (               ),
  .ena_o    (               )
);

endmodule

