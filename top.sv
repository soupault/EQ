`include "edge_detector.sv"
`include "decoder.sv"
`include "testbench/dut_if.sv"
`include "megafunctions/fifo.v"

`include "fifo_reader.sv"
//`include "filter.sv"
`include "regfile.v"
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

logic [23:0]  data_fifo2filt_w;
logic         ena_fifo2filt_w;

regfile regfile
(
  .clk_i      ( main_if.clk   ),
  .rst_i      ( ~main_if.nrst ),
  
  .data_i     ( '0            ),
  .wren_i     ( '0            ),
  .addr_i     ( '0            ),
  .data_o     (               ),

  .sreg_i     ( '0            ),
  .creg_o     (               ) 
);

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

// TODO: status fifo
/*
preamble_w
package_w[VALIDITY]
package_w[USER_DATA]
package_w[CHNL_STATUS]
package_w[PARITY]
*/

// TODO: think about lost/corrupt frames interpolation
fifo data_fifo
(
// TODO: parameter data width
// TODO: parameter depth
	.aclr       ( ~main_if.nrst ),
	.data       ( { package_w[AUDIO_SAMPLE],
                  package_w[AUX_SAMPLE] } ),
	.rdclk      ( main_if.clk6  ),
	.rdreq      ( rdreq_w       ),
	.wrclk      ( main_if.clk   ),
	.wrreq      ( ena_dec2fifo_w),

	.q          ( rddata_w      ),
	.rdempty    ( rdempty_w     ),
	.rdfull     ( rdfull_w      ),
	.rdusedw    ( rdusedw_w     ),
	.wrempty    (               ),
	.wrfull     (               ),
	.wrusedw    (               )
);

fifo_reader data_fifo_reader
(
  .clk_i      ( main_if.clk   ),
  .nrst_i     ( main_if.nrst  ),
  
  .data_i     ( rddata_w      ), 

	.empty_i    ( rdempty_w     ),
	.full_i     ( rdfull_w      ), 
	.usedw_i    ( rdusedw_w     ),
         
	.rdreq_o    ( rdreq_w       ),
  .data_o     ( data_fifo2filt_w ),
  .ena_o      ( ena_fifo2filt_w  ) 
);

/*
filter filter
(
  .clk_i      ( main_if.clk   ),
  .nrst_i     ( main_if.nrst  ),
  
  .data_i     ( data_fifo2filt_w ),
  .ena_i      ( ena_fifo2filt_w  ),
  .coeff_i    ( '0            ),

  .data_o     (               ),
  .ena_o      (               )
);
*/
endmodule

