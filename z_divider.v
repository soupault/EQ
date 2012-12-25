// Author: Egor Panfilov
// For: dividing clock freq over 3

module divider (
	input clk,
	input nreset,
	output clk_over3
);

	reg [2:0] reg0;
	reg reg1, reg2;
	
/*	initial
	begin
		reg0[2:0] <= 3'b0;
		reg1 <= 1'b1;
		reg2 <= 1'b1;
	end */
	
	always@(posedge clk)
	begin
		reg0[2:0] <= {reg0[1:0], ~reg0[2]};
		reg1 <= reg0[2];
	end
	
	always@(negedge clk)
	begin
		reg2 <= reg1;
	end
	
	always@(negedge nreset)
	begin
		reg0[2:0] <= 3'b0;
		reg1 <= 1'b1;
		reg2 <= 1'b1;
	end
	
	assign clk_over3 = reg0[2] ^~ reg2;

endmodule
