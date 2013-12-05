module assembly
(
	input               zero_i,
	input               one_i,
	input               head_i,
	input               nrst_i,
	input               clk_i,
	input               ena_i,

	output logic [27:0] package_o,
	output logic        ready_o
);

logic [7:0]   shift_reg;
logic [55:0]  package_reg;
logic [5:0]   counter;
logic [6:0]   i;

logic         det_X;
logic         det_Y;
logic         det_Z;

// TODO: add 2 bits of preamble code in output reg
// TODO: filling output reg with fixed frequency (?)
// !!! TODO: check if pkg[i] and pkg[i+1] are equal for even i
// FYI: cut 4 bits of package_o

localparam pre_X = 8'b11100010;
localparam pre_Y = 8'b11100100;
localparam pre_Z = 8'b11101000;

// localparam pattern_0 = 4'b0110;
// localparam pattern_1 = 3'b010;
localparam pattern_0 = 2'b11;
localparam pattern_1 = 2'b10;

always @(posedge clk_i or negedge nrst_i)
begin
	if (~nrst_i) begin
		package_o = 28'd0;
		ready_o = 1'b0;
		shift_reg = 8'd0;
		package_reg = 28'd0;
		counter = 6'd0;
		det_X = 1'b0;
		det_Y = 1'b0;
		det_Z = 1'b0;
	end else begin
		if (ena_i) begin
			
			/* Create data-flow */
			case ({head_i, one_i, zero_i})
				3'b001: shift_reg <= {shift_reg[5:0], {2{~shift_reg[0]}}};
				3'b010: shift_reg <= {shift_reg[6:0], ~shift_reg[0]};
				3'b100: shift_reg <= {shift_reg[4:0], {3{~shift_reg[0]}}};
				default: ;
			endcase
			
			/* Classify preamble */
			if ((shift_reg == pre_X) || (shift_reg == ~pre_X)) det_X <= 1'b1;
				else det_X <= 1'b0;
			if ((shift_reg == pre_Y) || (shift_reg == ~pre_Y)) det_Y <= 1'b1;
				else det_Y <= 1'b0;
			if ((shift_reg == pre_Z) || (shift_reg == ~pre_Z)) det_Z <= 1'b1;
				else det_Z <= 1'b0;
			
			/* Try to latch correct package on next preamble */
			if (head_i & (counter == 6'd54)) begin
				for (i = 0; i < 28; i = i+1) begin
					package_o[i] <= package_reg[i<<1];
				end
				ready_o <= 1'b1;
			end else
				ready_o <= 1'b0;
			
			/* Decode and create audio-block */
			if ((shift_reg[1:0] == pattern_0) || (shift_reg[1:0] == ~pattern_0)) begin
				package_reg <= {package_reg[54:0], 1'b0};
			end
			if ((shift_reg[1:0] == pattern_1) || (shift_reg[1:0] == ~pattern_1)) begin
				package_reg <= {package_reg[54:0], 1'b1};
			end
			
			/* Restart packager module */
			// head_i IS A WIRE, so no delay here
			if (((det_X || det_Y) || det_Z) || (head_i & (counter == 6'd54))) counter <= 6'd0;	
			else if (((shift_reg[1:0] == pattern_0) || (shift_reg[1:0] == ~pattern_0)) || ((shift_reg[1:0] == pattern_1) || (shift_reg[1:0] == ~pattern_1))) counter <= counter + 1'b1;
			
		end
	end
end

endmodule
