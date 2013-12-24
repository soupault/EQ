module amplifier
(
  input               clk_i,
  input               nrst_i,
  
  input        [23:0] data_i,
  input         [7:0] rate_i,
  input               ena_i,

  output logic [23:0] data_o,
  output logic        ena_o
);

logic [23:0][23:0]    data_cutted_w;

genvar i;
generate
  for( i = 0; i <= 23; i=i+1 )
    assign data_cutted_w[i] = { '0, data_i[23:i] };
endgenerate

always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    data_o <= '0;
  else
    if( ena_i )
      case( rate_i[7] )
        1'b1:
          if( data_cutted_w[rate_i[6:0]] )
            data_o <= '1;
          else
            data_o <= ( data_i << rate_i[6:0] );
        1'b0:
            data_o <= ( data_i >> rate_i[6:0] );
      endcase

always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    ena_o <= '0;
  else
    ena_o <= ena_i;

endmodule

