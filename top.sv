`include "edge_detector.sv"
`include "decoder.sv"
`include "testbench/dut_if.sv"

`include "subframe.svh"

module top
(
  dut_if  main_if
);

logic   short_w;
logic   mid_w;
logic   long_w;
logic   ena_ed2dec_w;

logic [27:0]  package_w;
logic [2:0]   preamble_w;
logic         ena_dec2fifo_w;

edge_detector edge_detector
(
  .spdif_i    ( main_if.spdif ),
  .clk_i      ( main_if.clk6  ),
  .nrst_i     ( main_if.nrst  ),

  .short_o    ( short_w       ),
  .mid_o      ( mid_w         ),
  .long_o     ( long_w        ),
  .ena_o      ( ena_ed2dec_w  )
);

decoder decoder
(
  .short_i    ( short_w       ),
  .mid_i      ( mid_w         ),
  .long_i     ( long_w        ),
  .ena_i      ( ena_ed2dec_w  ),

  .clk_i      ( main_if.clk6  ),
  .nrst_i     ( main_if.nrst  ),

  .package_o  ( package_w     ),
  .preamble_o ( preamble_w    ),
  .ena_o      ( ena_dec2fifo_w)
);

// TODO: add data and status FIFOs
// TODO: think about lost frames interpolation
// status fifo
/*
preamble_w
package_w[VALIDITY]
package_w[USER_DATA]
package_w[CHNL_STATUS]
package_w[PARITY]
*/

// data fifo
/*
package_w[AUDIO_SAMPLE],
package_w[AUX_SAMPLE]
*/

// TODO: add control/status registers


endmodule

