module filter (
   input wire [23:0] i_sample,
   input wire [15:0] i_coefficients [0:order-1],
	input wire i_start,
	input wire i_rst_n,
	input wire i_clk,
	
	output reg [43:0] o_result, // width = i_sample + i_coefficient + log2(order) [rounded upwards]
   output wire o_ready
);

	localparam order = 12;
	
	reg ff_delay;
	
	reg [23:0] buffer_in [0:order-1];
	reg [23:0] buffer_out [0:order-1];
	wire [order-1:0] buffer_ready;
	
	reg [40:0] reg_sum0 [0:5];
	wire [40:0] wire_sum0 [0:5];
	reg [41:0] reg_sum1 [0:2];
	wire [41:0] wire_sum1 [0:2];
	reg [42:0] reg_sum2;
	wire [42:0] wire_sum2;
	reg [43:0] reg_sum3;
	wire [43:0] wire_sum3;
	
	generate
		genvar i;
		for (i = 0; i < order; i = i+1) begin: cascade0
			multunit inst (
				.i_sample 		(buffer_in[i]),
				.i_coefficient	(i_coefficients[i]),
				.i_start			(i_start),
				.i_rst_n 		(i_rst_n),
				.i_clk			(i_clk),
				.o_product		(buffer_in[i]),
				.o_ready			(buffer_ready[i])
			);
		end
		
		for (i = 0; i < order/2; i = i+1) begin: cascade1
			assign wire_sum0[i] = buffer_out[2*i] + buffer_out[2*i+1]; // 6 buses
		end
		
		for (i = 0; i < order/4; i = i+1) begin: cascade2
			assign wire_sum1[i] = reg_sum0[i] + reg_sum0[i+1]; // 3 buses
		end
	endgenerate
	
	assign wire_sum2 = reg_sum1[0] + reg_sum1[1]; // 1 bus
	assign wire_sum3 = reg_sum2 + reg_sum1[2]; // 1 bus
	
always @(posedge i_clk or negedge i_rst_n)
begin
	if (~i_rst_n) begin
		/*	*/
	end else begin
		reg_sum0[5:0] <= wire_sum0[5:0];
		reg_sum1[2:0] <= wire_sum1[2:0];
		reg_sum2 <= wire_sum2;
		reg_sum3 <= wire_sum3;
		
		if (o_result != reg_sum3) begin
			o_result <= reg_sum3;
			ff_delay <= 1'b1;
		end else
			ff_delay <= 1'b0;
			
		o_ready <= ff_delay;
		
		if (i_start)
			buffer_in[order-1:0] = {buffer_in[order-2:0], i_sample};
	end
end

endmodule
