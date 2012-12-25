`timescale 1ns/100ps

module testbench_B;

parameter T = 10;

reg spdif_in, rst_n, clk;
reg [87:0] time_vector;
reg [6:0] cntr;
wire [2:0] flag;
wire enable;
wire [24:0] bfr;

core core1(spdif_in, rst_n, clk, flag, enable, bfr);

initial
begin
	clk = 0;
	rst_n = 0;
	spdif_in = 0;
end
	
always 
	#(T/2) clk = ~clk;

initial
begin
	#1 rst_n = 1'b0;
	time_vector = 88'b10110010101100_10_11100010_1100101010101100101011001010110010101010110011001011001011001100; // 14 2 8 64
	#4 rst_n = 1'b1;
end

initial
begin
	#(2.5*T) spdif_in = 1'b1;
	for (cntr = 87; cntr >= 0; cntr = cntr - 1)
		#(3*T) spdif_in = time_vector[cntr];		
end

initial
begin
   $display("\t\ttime,\tclk,\treset,\tspdif,\tflag_out,\tena_out");
   $monitor("%d,\t%b,\t%b,\t%b,\t%b,\t%b", $time, clk, ~rst_n, spdif_in, flag, enable); 
end 

endmodule
