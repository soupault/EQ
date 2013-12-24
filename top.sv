`include "testbench/dut_if.sv"
`include "regfile.v"
`include "edge_detector.sv"
`include "decoder.sv"
`include "fifo_reader.sv"
`include "amplifier.sv"
`include "subframe.svh"

`include "megafunctions/fifo.v"
`include "megafunctions/to_float.v"
`include "megafunctions/from_float.v"

`include "filters/lowpass_filter.v"
`include "filters/highpass_filter.v"

module top
(
  dut_if  main_if
);

logic [7:0]   rate_lp_amp_w;
logic [7:0]   rate_hp_amp_w;

logic         short_w;
logic         mid_w;
logic         long_w;
logic         ena_ed2dec_w;

logic [27:0]  package_w;
logic [1:0]   preamble_w;
logic         ena_dec2fifo_w;

logic         rdreq_w;
logic [23:0]  rddata_w;
logic         rdempty_w;
logic         rdfull_w;
logic [2:0]   rdusedw_w;

logic         ena_fifo_w;
logic [19:0]  ena_fifo_d;

logic [23:0]  data_fifo2conv_w;
logic [63:0]  data_conv2filt_w;
logic [63:0]  data_lp2conv_w;
logic [63:0]  data_hp2conv_w;
logic [23:0]  data_conv2lpgain_w;
logic [23:0]  data_conv2hpgain_w;
logic [23:0]  data_lpgain2sum_w;
logic [23:0]  data_hpgain2sum_w;

logic         ena_pcm_w;


// Status/control registers
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

// TODO: get from regfile
assign rate_lp_amp_w = 8'b0;
assign rate_hp_amp_w = 8'b0;

// Classify gap between edges
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

// Look for header and decode data from BMC
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

// Store parsed data in FIFO
// TODO: think about lost/corrupt frames interpolation
fifo data_fifo
(
// TODO: parameter data width
// TODO: parameter depth
	.aclr       ( ~main_if.nrst ),
	.data       ( { package_w[`AUDIO_SAMPLE],
                  package_w[`AUX_SAMPLE] } ),
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
  .data_o     ( data_fifo2conv_w ),
  .ena_o      ( ena_fifo_w    ) 
);

always_ff @( posedge main_if.clk or negedge main_if.nrst )
  if( ~main_if.nrst )
    ena_fifo_d <= '0;
  else
    ena_fifo_d <= { ena_fifo_d, ena_fifo_w };

// Convert 24 bit sample to double float
to_float to_float
(
	.clock      ( main_if.clk   ),
	.aclr       ( ~main_if.nrst ),
	.dataa      ( data_fifo2conv_w ),
	.result     ( data_conv2filt_w )
);

// 6 ticks on convert to float
assign ena_conv_direct_w = ena_fifo_d[5];

// ************************* Lowpass channel ****************************** //
lowpass_filter lowpass_filter
(
  .clk_i      ( main_if.clk   ),
  .nrst_i     ( main_if.nrst  ),
  .clkena_i   ( ena_conv_direct_w),
  .filter_i   ( data_conv2filt_w ),
  .filter_o   ( data_lp2conv_w   )
);

// Convert from double float to 24 bit integer
from_float lp_from_float
(
	.clock      ( main_if.clk   ),
	.aclr       ( ~main_if.nrst ),
	
  .dataa      ( data_lp2conv_w ),
	.result     ( data_conv2lpgain_w ),
	.overflow   (               ),
	.underflow  (               )
);

// -1 tick  on ena_fifo_w
//  6 ticks on convert to float
//  6 ticks on filtering
//  6 ticks on convert from float
assign ena_amp_w = ena_fifo_d[16];

amplifier lp_amplifier
(
	.clk_i      ( main_if.clk   ),
	.nrst_i     ( main_if.nrst  ),
  
  .data_i     ( data_conv2lpgain_w ),
  .rate_i     ( rate_lp_amp_w ),
  .ena_i      ( ena_amp_w     ),

  .data_o     ( data_lpgain2sum_w  ),
  .ena_o      ( ena_pcm_w     )
);

// **************************** Highpass channel ************************** //
highpass_filter highpass_filter
(
  .clk_i      ( main_if.clk   ),
  .nrst_i     ( main_if.nrst  ),
  .clkena_i   ( ena_conv_direct_w),
  .filter_i   ( data_conv2filt_w ),
  .filter_o   ( data_hp2conv_w   )
);

// Convert from double float to 24 bit integer
from_float hp_from_float
(
	.clock      ( main_if.clk   ),
	.aclr       ( ~main_if.nrst ),
	
  .dataa      ( data_hp2conv_w ),
	.result     ( data_conv2hpgain_w ),
	.overflow   (               ),
	.underflow  (               )
);

amplifier hp_amplifier
(
	.clk_i      ( main_if.clk   ),
	.nrst_i     ( main_if.nrst  ),
  
  .data_i     ( data_conv2hpgain_w ),
  .rate_i     ( rate_hp_amp_w ),
  .ena_i      ( ena_amp_w     ),

  .data_o     ( data_hpgain2sum_w  ),
  .ena_o      (               ) // no need. use one from lowpass channel
);


// Latch data to output
always_ff @( posedge main_if.clk or negedge main_if.nrst )
  if( ~main_if.nrst )
    main_if.pcm <= '0;
  else
    if( ena_pcm_w )
      begin
        // overflow is possible
        if( data_lpgain2sum_w + data_hpgain2sum_w >= {24{1'b1}} )
          main_if.pcm <= '1;
        else
          main_if.pcm <= data_lpgain2sum_w + data_hpgain2sum_w;
      end

always_ff @( posedge main_if.clk or negedge main_if.nrst )
  if( ~main_if.nrst )
    main_if.pcm_ena <= '0;
  else
    main_if.pcm_ena <= ena_pcm_w;

endmodule

