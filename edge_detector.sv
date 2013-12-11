module edge_detector
(
  input         spdif_i,
  input         nrst_i,
  input         clk_i,
  
  output logic  short_o,
  output logic  mid_o,
  output logic  long_o,
  output logic  ena_o
);

logic [2:0] spdif_d;
logic 		  spdif_stb;

logic [4:0] counter;

// ****** Registering input and metastability fix ******
always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    spdif_d <= '0;
  else
    spdif_d <= { spdif_d[1:0], spdif_i };

assign spdif_stb = spdif_d[2] ^ spdif_d[1];

// ****** Counting ticks in a gap ******
always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    counter <= '0;
  else
    begin
      if( spdif_stb )
        counter <= '0;
      else
        counter <= counter + 1'b1;
    end

// ****** Generating output enable strobe ******
always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    ena_o <= '0;
  else
    ena_o <= spdif_stb;

// ****** Generating output data signal ******
always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    begin
      short_o <= '0;
      mid_o   <= '0;
      long_o  <= '0;
    end
  else
    begin
      short_o <= ( counter >= 5'd3  ) & ( counter <= 5'd7  );
      mid_o   <= ( counter >= 5'd9  ) & ( counter <= 5'd13 );
      long_o  <= ( counter >= 5'd15 ) & ( counter <= 5'd19 );
    end

endmodule

