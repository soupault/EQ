module decoder (i_spdif, i_rst_n, clk, ena, o_decoded_data, o_decoder_clk/*, tb_blivet, tb_window*/);

input wire i_spdif, i_rst_n, clk, ena;
output wire o_decoded_data, o_decoder_clk;
/*output wire tb_blivet, tb_window;*/

reg ff_bfr;
reg ff_in;
reg [4:0] ff_w;

wire tmp_wire, data_wire;
wire blivet, window;

assign blivet = ff_in ^ ff_bfr; // xor
assign window = (ff_w[1] | ff_w[2]) | ff_w[3];
assign o_decoder_clk = ff_w[4];

/*assign tb_blivet = blivet;
assign tb_window = window;*/

FFE ff_out1 (.d(1'b1), .clk(clk), .clrn(~ff_w[4] & i_rst_n), .ena(window & blivet), .q(tmp_wire));
FFE ff_out2 (.d(tmp_wire), .clk(clk), .clrn(i_rst_n), .ena(ff_w[3]), .q(o_decoded_data));

always @(posedge clk or negedge i_rst_n)
begin
	if (~i_rst_n) begin
		ff_bfr <= 1'd0;
		ff_in <= 1'd0;
		ff_w <= 5'd0;
	end else begin
		if (ena)
			ff_bfr <= i_spdif;
			
		// changeover detector
			ff_in <= ff_bfr;
			// decoded clock
			ff_w[0] <= blivet & ~window;
			ff_w[4:1] <= ff_w[3:0];
	end
end

/*always @(negedge o_decoded_clk)
begin
	if counter == 27
	o_data_bus[27:0] <= {o_data_bus[26:0], o_decoded_data};
end*/

endmodule
