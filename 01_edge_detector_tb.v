`timescale 1 ns / 1 ps

module edge_detector_tb;

	reg i_spdif;
	reg i_rst_n;
	reg i_clk;
//	reg i_ena;
	wire o_zero;
	wire o_one;
	wire o_head;
	wire o_shift_ena;

	parameter period = 10; // TODO: check the value
	reg [231:0] data;
	reg [7:0] pointer;
	
	event reset_on;
	event reset_off;
	event bit_flip;
	event long_pulse;
	
edge_detector inst0 (
	.i_spdif		(i_spdif),
	.i_rst_n		(i_rst_n),
	.i_clk		(i_clk),
//	.i_ena		(i_ena),
	.o_zero		(o_zero),
	.o_one		(o_one),
	.o_head		(o_head),
	.o_shift_ena(o_shift_ena)
);

	initial begin
		i_spdif = 0;
		i_rst_n = 0;
		i_clk = 0;
//		i_ena = 0;
		data = {1'b0, {2{1'b1}}, {3{1'b0}}, {4{1'b1}}, {5{1'b0}}, {6{1'b1}}, {7{1'b0}}, {8{1'b1}}, {9{1'b0}}, {10{1'b1}}, {11{1'b0}}, {12{1'b1}}, {13{1'b0}}, {14{1'b1}},
				{15{1'b0}}, {16{1'b1}}, {17{1'b0}}, {18{1'b1}}, {19{1'b0}}, {20{1'b1}}, {21{1'b0}}, {1{1'b1}}};
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
		#(period/2);
//		#(2*period) i_ena = 1;
		pointer = 231;
		repeat(231) begin
			pointer = pointer - 1;
			#(period) i_spdif = data[pointer];
		end	
		#(10*period);
   end
	
	/* Results */
	initial begin
		$dumpfile ("edge_detector.vcd");
		$dumpvars;
	end 
    
	initial begin
//		$display("\t\ttime,\tclk,\treset,\tenable,\ti_spdif,\to_0,\to_1,\to_h,\to_shift");
//		$monitor("%d,\t%b,\t%b,\t%b,\t%b,\t%b,\t%b,\t%b,\t%b,", $time, i_clk, i_rst_n, i_ena, i_spdif, o_zero, o_one, o_head, o_shift_ena);
		$display("\t\ttime,\tclk,\treset,\ti_spdif,\to_0,\to_1,\to_h,\to_shift");
		$monitor("%d,\t%b,\t%b,\t%b,\t%b,\t%b,\t%b,\t%b,", $time, i_clk, i_rst_n, i_spdif, o_zero, o_one, o_head, o_shift_ena);
	end
	
endmodule
