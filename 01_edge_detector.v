module edge_detector (
  input  wire  i_spdif,
  input  wire  i_rst_n,
  input  wire  i_clk,
	
  output reg   o_zero,
  output reg   o_one,
  output reg   o_head,
  output reg   o_ena
);

reg   [2:0] spdif_d;
wire        spdif_str;

reg   [4:0] counter;

// ****** Registering input and metastability fix ******
always @( posedge i_clk or negedge i_rst_n )
  begin
    if( ~i_rst_n )
      begin
        ff_bfr <= 3'd0;
      end
    else
      begin
        spdif_d <= { spdif_d[1:0], i_spdif };
      end
  end

assign spdif_str = spdif_d[2] ^ spdif_d[1];

// ****** Counting ticks in a gap ******
always @( posedge i_clk or negedge i_rst_n )
  begin
    if( ~i_rst_n )
      begin
        counter <= 5'b0;
      end
    else
      begin
        if( spdif_str )
          counter <= 5'b0;
        else
          counter <= counter + 1'b1;
      end
  end

// ****** Generating output enable strobe ******
always @( posedge i_clk or negedge i_rst_n )
  begin
    if( ~i_rst_n )
      begin
        o_ena <= 1'b0;
      end
    else
      begin
        if( spdif_str )
          o_ena <= 1'b1;
        else
          o_ena <= 1'b0;
      end
  end

assign o_zero = ( counter >= 5'd3  ) & ( counter <= 5'd7  );
assign o_one  = ( counter >= 5'd9  ) & ( counter <= 5'd13 );
assign o_head = ( counter >= 5'd15 ) & ( counter <= 5'd19 );

endmodule

