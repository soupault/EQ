module decoder (i_spdif, i_rst_n, clk, ena, o_decoded_data, o_decoder_clk, tb_blivet, tb_window);

input wire i_spdif, i_rst_n, clk, ena;
output wire o_decoded_data, o_decoder_clk;
output wire tb_blivet, tb_window;

reg ff_bfr;
reg ff_in;
reg [4:0] ff_w;
reg [1:0] ff_d;

wire tmp_wire, data_wire;
wire blivet, window;

assign blivet = ff_in ^ ff_bfr; // xor
assign window = (ff_w[1] | ff_w[2]) | ff_w[3];
assign o_decoded_data = data_wire;
assign o_decoder_clk = ff_w[4];

assign tb_blivet = blivet;
assign tb_window = window;

FFE ff_out1 (.d(1'b1), .clk(window & blivet), .clrn(~ff_w[4] & i_rst_n), .ena(1'b1), .q(tmp_wire));
FFE ff_out2 (.d(tmp_wire), .clk(ff_w[4]), .clrn(i_rst_n), .ena(1'b1), .q(data_wire));

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

endmodule
