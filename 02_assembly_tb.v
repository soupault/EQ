`timescale 1 ns / 1 ps

module assembly_tb;

	reg i_zero;
	reg i_one;
	reg i_head;
	reg i_rst_n;
	reg i_clk;
	reg i_ena;
	wire [27:0] o_package;
	wire o_ready;
	
	parameter period = 10; // ???? TODO: check the value
	reg [55:0] data_common1;
	reg [59:0] data_h1;
	reg [59:0] data_01;
	reg [59:0] data_11;
	
	reg [55:0] data_common2;
	reg [59:0] data_h2;
	reg [59:0] data_02;
	reg [59:0] data_12;
	reg [7:0] pointer;
	
	event reset_on;
	event reset_off;
	
assembly inst0 (
	.i_zero		(i_zero), 
	.i_one		(i_one),
	.i_head		(i_head), 
	.i_rst_n		(i_rst_n), 
	.i_clk		(i_clk), 
	.i_ena		(i_ena), 
	.o_package	(o_package), 
	.o_ready		(o_ready)
);

	initial begin
		i_zero = 0;
		i_one = 0;
		i_head = 0;
		i_rst_n = 0;
		i_clk = 1;
		i_ena = 0;
		
		//	30 bits			111111111111111111111111111111
		data_common1 = 56'b11110011000000110000110011000011110011000000110000110011;
		data_h1 = {4'b1100, 56'd0}; // head
		data_01 = {4'b0000, ~data_common1};
		data_11 = {4'b0011, data_common1};
		data_common2 = 56'b11000011001100111100001100001111110000110000000011110011;
		data_h2 = {4'b1001, 56'd0}; // head
		data_02 = {4'b0000, ~data_common2};
		data_12 = {4'b0110, data_common2};
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
		#(2*period) i_ena = 1;
		
		repeat(10) begin
			pointer = 60;
			repeat(60) begin
				pointer = pointer - 1;
				i_head = data_h1[pointer];
				i_zero = data_01[pointer];
				i_one = data_11[pointer];
				#(period);
			end	
			
			pointer = 60;
			repeat(60) begin
				pointer = pointer - 1;
				i_head = data_h2[pointer];
				i_zero = data_02[pointer];
				i_one = data_12[pointer];
				#(period);
			end	
		end
		
		#(10*period);
   end
	
	/* Results */
	initial begin
		$dumpfile ("assembly.vcd");
		$dumpvars;
	end 
    
	initial begin
		$display("\t\ttime,\tclk,\treset_n,\tenable,\ti_0,\ti_1,\ti_h,\to_pkg,\to_ready");
		$monitor("%d,\t%b,\t%b,\t%b,\t%b,\t%b,\t%b,\t%d,\t%b", $time, i_clk, i_rst_n, i_ena, i_zero, i_one, i_head, o_package, o_ready);
	end
	
endmodule
