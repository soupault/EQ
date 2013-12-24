module fifo_reader
#(
  parameter SHOW_AHEAD = 1,
  parameter D_WIDTH = 24
)
(
  input               clk_i,
  input               nrst_i,
  
  input [D_WIDTH-1:0] data_i,

	input               empty_i,
	input               full_i, 
	input               usedw_i, // TODO: fix width
         
	output logic                rdreq_o,
  output logic [D_WIDTH-1:0]  data_o,
  output logic                ena_o
);

// TODO: add 'generate-if' for not show_ahead fifo

always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    data_o <= '0;
  else
    if( ~empty_i )
      data_o <= data_i;

always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    ena_o <= '0;
  else
    if( ~empty_i )
      ena_o <= '1;
    else
      ena_o <= '0;

always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    rdreq_o <= '0;
  else
    if( ~empty_i )
      rdreq_o <= '1;
    else
      rdreq_o <= '0;

endmodule

