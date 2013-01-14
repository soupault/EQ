`timescale 1 ns / 1 ps

module mult_unit_tb;

	reg [23:0] i_sample;
	reg [15:0] i_coefficient;
	reg i_start;
	reg i_rst_n;
	reg i_clk;
	
	wire [39:0] o_product;
   wire o_ready;
	
	parameter period = 10; // TODO: check the value
	
	event reset_on;
	event reset_off;
	
mult_unit inst0 (
	.i_sample		(i_sample),
	.i_coefficient	(i_coefficient),
	.i_start			(i_start),
	.i_rst_n			(i_rst_n),
	.i_clk			(i_clk),
	.o_product		(o_product),
	.o_ready			(o_ready)
);

	initial begin
		i_rst_n = 0;
		i_clk = 1;
		i_start = 0;
		//i_sample = 24'bX;
		i_sample = 24'b110101001000110101110010;
		//i_coefficient = 16'bX;
		i_coefficient = 16'b1100010111010101;
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
		#(2*period) i_start = 1;
		#(2*period) i_start = 0;		
		
		#(100*period);
   end
	
	/* Results */
	initial begin
		$dumpfile ("mult_unit.vcd");
		$dumpvars;
	end 
   
	initial begin
		$display("\t\ttime,\ti_clk,\ti_reset_n,\ti_start,\ti_sample,\ti_coefficient,\to_product,\to_ready");
		$monitor("%d,\t%b,\t%b,\t%b,\t%d,\t%d,\t%d,\t%b", $time, i_clk, i_rst_n, i_start, i_sample, i_coefficient, o_product, o_ready);
	end

endmodule
