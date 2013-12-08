module edge_detector
(
  input         spdif_i,
  input         nrst_i,
  input         clk_i,
  
  output logic  one_o,
  output logic	two_o,
  output logic	three_o,
  output logic	ena_o
);

logic [2:0] spdif_d;
logic 		  spdif_str;

logic [4:0] counter;

// ****** Registering input and metastability fix ******
always_ff @( posedge clk_i or negedge nrst_i )
  begin
    if( ~nrst_i )
      spdif_d <= 3'd0;
    else
      spdif_d <= { spdif_d[1:0], spdif_i };
  end

assign spdif_str = spdif_d[2] ^ spdif_d[1];

// ****** Counting ticks in a gap ******
always_ff @( posedge clk_i or negedge nrst_i )
  begin
    if( ~nrst_i )
      counter <= 5'b0;
    else
      begin
        if( spdif_str )
          counter <= 5'b0;
        else
          counter <= counter + 1'b1;
      end
  end

// ****** Generating output enable strobe ******
always_ff @( posedge clk_i or negedge nrst_i )
  begin
    if( ~nrst_i )
      ena_o <= 1'b0;
    else
      begin
        if( spdif_str )
          ena_o <= 1'b1;
        else
          ena_o <= 1'b0;
      end
  end

assign one_o   = ( counter >= 5'd3  ) & ( counter <= 5'd7  );
assign two_o   = ( counter >= 5'd9  ) & ( counter <= 5'd13 );
assign three_o = ( counter >= 5'd15 ) & ( counter <= 5'd19 );

endmodule

