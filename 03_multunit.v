module multunit (
   input wire [23:0] i_sample,
   input wire [15:0] i_coefficient,
	input wire i_start,
	input wire i_rst_n,
	input wire i_clk,
	
	output reg [39:0] o_product,
   output wire o_ready
);

	reg lsb;
	reg [4:0] pointer;
	
	assign o_ready = !pointer;
   
always @(posedge i_clk or negedge i_rst_n)
begin
	if (~i_rst_n) begin
		o_product = 40'd0;
		pointer = 5'd0;
		lsb = 1'b0;
	end else begin
		if (o_ready && i_start) begin
			pointer = 16;
			o_product = {24'd0, i_coefficient};
		end else if (pointer) begin
			lsb = o_product[0];
			o_product = o_product >> 1;
			pointer = pointer - 1;
			if (lsb) o_product[39:15] = o_product[38:15] + i_sample;
		end
	end
end

endmodule
