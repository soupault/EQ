module filter 
	#(parameter order = 4)
	(
   input wire [23:0] i_sample,
	input wire [(16*order-1):0] i_coefficients_flat,
	input wire i_start,
	input wire i_rst_n,
	input wire i_clk,
	
	output reg [41:0] o_result, // width = i_sample + i_coefficients + log2(order) [rounded upwards]
   output reg o_ready
);

	wire [15:0] i_coefficients [0:order-1];

	reg [23:0] buffer_in [0:order-1];
	wire [39:0] buffer_out [0:order-1];

	wire [order-1:0] buffer_ready;
	
	reg [40:0] reg_sum0 [0:1];
	wire [40:0] wire_sum0 [0:1];
	reg [41:0] reg_sum1;
	wire [41:0] wire_sum1;

	reg ff_delay, ff_d0, ff_d1, ff_d2;

	reg [3:0] k;
	
	generate
		genvar i;
		for (i = 0; i < order; i = i+1) begin: pack
			assign i_coefficients[i] = i_coefficients_flat[(16*i + 15):(16*i)];
		end
		
		for (i = 0; i < order; i = i+1) begin: multipliers
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
	endgenerate
	
	assign wire_sum0[0] = buffer_out[0] + buffer_out[1];
	assign wire_sum0[1] = buffer_out[2] + buffer_out[3];
	assign wire_sum1 = reg_sum0[0] + reg_sum0[1];	
	
always @(posedge i_clk or negedge i_rst_n)
begin
	if (~i_rst_n) begin
		ff_delay = 0;
		o_result = 42'd0;
		o_ready = 0;
		
		for (k = 0; k < order; k = k+1) begin
			buffer_in[k] = 0;
		end
		
		reg_sum0[0] = 0;
		reg_sum0[1] = 0;
		reg_sum1 = 0;
		
		/*	 */
	end else begin
		ff_d0 = (&buffer_ready);
		ff_d1 = ff_d0;
		ff_d2 = ff_d1;
		
		if (ff_d0)
			reg_sum0[0] <= wire_sum0[0];
		if (ff_d1)
			reg_sum0[1] <= wire_sum0[1];
		if (ff_d2)
			reg_sum1 <= wire_sum1;
		
		if (o_result != reg_sum1) begin
			o_result <= reg_sum1;
			ff_delay <= 1'b1;
		end else
			ff_delay <= 1'b0;
			
		o_ready <= ff_delay;
		
		if (i_start)
			for (k = 0; k < order; k = k+1) begin
				if (k == 0)
					buffer_in[k] <= i_sample;
				else
					buffer_in[k] <= buffer_in[k-1];
			end
	end
end

endmodule
