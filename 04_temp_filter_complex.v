module filter 
	#(parameter order = 12)
	(
   input wire [23:0] i_sample,
   //input wire [15:0] i_coefficients [0:order-1],
	input wire [(16*order-1):0] i_coefficients_flat,
	input wire i_start,
	input wire i_rst_n,
	input wire i_clk,
	
	output reg [43:0] o_result, // width = i_sample + i_coefficients + log2(order) [rounded upwards]
   output reg o_ready
);

	reg [3:0] k;
	
	wire [15:0] i_coefficients [0:order-1];
	
	reg ff_delay;
	
	reg [23:0] buffer_in [0:order-1];
	wire [39:0] buffer_out [0:order-1];
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
		for (i = 0; i < order; i = i+1) begin: pack
			assign i_coefficients[i] = i_coefficients_flat[(16*i + 15):(16*i)];
		end
		
		for (i = 0; i < order; i = i+1) begin: cascade0
			multunit inst (
				.i_sample 		(buffer_in[i]),
				.i_coefficient	(i_coefficients[i]),
				.i_start			(i_start),
				.i_rst_n 		(i_rst_n),
				.i_clk			(i_clk),
				.o_product		(buffer_out[i]),
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
		ff_delay = 0;
		o_result = 44'd0;
		o_ready = 0;
		
		for (k = 0; k < order; k = k+1) begin
			buffer_in[k] = 0;
			//buffer_out[k] = 0;
		end
		
		for (k = 0; k < 6; k = k+1) begin
			reg_sum0[k] = 0;
		end
		
		for (k = 0; k < 3; k = k+1) begin
			reg_sum1[k] = 0;
		end
		
		reg_sum2 = 0;
		reg_sum3 = 0;
		/*	 */
	end else begin
	// check ready signals from multipliers
		for (k = 0; k < 6; k = k+1) begin
			reg_sum0[k] <= wire_sum0[k];
		end
		
		for (k = 0; k < 3; k = k+1) begin
			reg_sum1[k] <= wire_sum1[k];
		end
		
		reg_sum2 <= wire_sum2;
		reg_sum3 <= wire_sum3;
		
		if (o_result != reg_sum3) begin
			o_result <= reg_sum3;
			ff_delay <= 1'b1;
		end else
			ff_delay <= 1'b0;
			
		o_ready <= ff_delay;
		
		if (i_start)
			//buffer_in[order-1:0] = {buffer_in[order-2:0], i_sample};
			for (k = 0; k < order; k = k+1) begin
				if (k == 0)
					buffer_in[k] <= i_sample;
				else
					buffer_in[k] <= buffer_in[k-1];
			end
	end
end

endmodule
