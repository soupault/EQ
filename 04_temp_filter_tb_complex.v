`timescale 1 ns / 1 ps

module filter_tb;

   parameter period = 10; // TODO: check the value
	parameter order = 12;
	
	reg [23:0] i_sample;
   reg [15:0] i_coefficients [0:order-1];
	reg i_start;
	reg i_rst_n;
	reg i_clk;
	
	wire [43:0] o_result;
   wire o_ready;

	reg [3:0] i;
	
	event reset_on;
	event reset_off;

	wire [(16*order-1):0] i_coefficients_flat;

	generate
		genvar k;
		for (k = 0; k < order; k = k+1) begin: unpack
			assign i_coefficients_flat[(16*k + 15):(16*k)] = i_coefficients[k];
		end
	endgenerate
	
filter inst0 (
	.i_sample				(i_sample),
	//.i_coefficients		(i_coefficients),
	.i_coefficients_flat	(i_coefficients_flat),
	.i_start					(i_start),
	.i_rst_n					(i_rst_n),
	.i_clk					(i_clk),
	.o_result				(o_result),
	.o_ready					(o_ready)
);
	
	initial begin
		i_rst_n = 0;
		i_clk = 1;
		i_start = 0;
		i_sample = 24'd0;
		for (i = 0; i < order; i = i+1) begin 
			i_coefficients[i] = (1 << i);
		end
	end
	
	always
		#(period/2) i_clk = ~i_clk;
		
	/* Reset logic */
	always @(reset_on) begin
		#(period) i_rst_n = 1;
		-> reset_off;
	end
	
	/* Main Routine */
	initial begin
		#(2*period) -> reset_on;
		@(reset_off);
		
		#(period) i_sample = 24'd0;
		#(period) i_start = 1;
		#(period) i_start = 0;		
		
		#(384*period) i_sample = 24'd16777215;
		#(period) i_start = 1;
		#(period) i_start = 0;
		
		repeat(16) begin
			#(384*period) i_sample = 24'd0;
			#(period) i_start = 1;
			#(period) i_start = 0;
		end
   end
	
	/* Results */
	initial begin
		$dumpfile ("filter.vcd");
		$dumpvars;
	end 
   
	initial begin
		$display("\t\ttime,\ti_clk,\ti_reset_n,\ti_start,\ti_sample,\ti_coefficients,\to_result,\to_ready");
		$monitor("%d,\t%b,\t%b,\t%b,\t%d,\t%p,\t%d,\t%b", $time, i_clk, i_rst_n, i_start, i_sample, i_coefficients, o_result, o_ready);
	end

endmodule
