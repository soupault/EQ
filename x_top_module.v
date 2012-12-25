module core (i_spdif, i_rst_n, clk, o_data, o_valid);

input wire i_spdif, i_rst_n, clk;
output reg [26:0] o_data;
output reg o_valid;

reg [30:0] buffer;
reg [1:0] ff_meta;
reg [2:0] flag;
wire enable;
wire serial_clk, serial_data;

core core1 (.i_spdif(ff_meta[1]), .i_rst_n(i_rst_n), .clk(clk), .o_flag(flag), .o_enable(enable));
decoder dcdr1 (.i_spdif(ff_meta[1]), .i_rst_n(i_rst_n), .clk(clk), .ena(enable), .o_decoded_data(serial_data), .o_decoder_clk(serial_clk));

always @(posedge clk or negedge i_rst_n)
begin
	if(~i_rst_n) begin
	
	end else begin
		ff_meta[0] <= i_spdif;
		ff_meta[1] <= ff_meta[0];
		
		if (serial_clk)
			o_data[23:0] <= {o_data[22:0], serial_data}
		
		// o_data[26:24] <= flag;
end
endmodule
