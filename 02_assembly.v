module assembly (
	input wire i_zero,
	input wire i_one,
	input wire i_head,
	input wire i_rst_n,
	input wire i_clk,
	input wire i_ena,

	output reg [27:0] o_package,
	output reg o_ready
);

reg [7:0] shift_reg;
reg [55:0] package_reg;
reg [5:0] counter;
reg [6:0] i;

reg det_X;
reg det_Y;
reg det_Z;

// TODO: add 2 bits of preamble code in output reg
// TODO: filling output reg with fixed frequency
// !!! TODO: check if pkg[i] and pkg[i+1] are equal for even i

localparam pre_X = 8'b11100010;
localparam pre_Y = 8'b11100100;
localparam pre_Z = 8'b11101000;

// localparam pattern_0 = 4'b0110;
// localparam pattern_1 = 3'b010;
localparam pattern_0 = 2'b11;
localparam pattern_1 = 2'b10;

always @(posedge i_clk or negedge i_rst_n)
begin
	if (~i_rst_n) begin
		o_package = 28'd0;
		o_ready = 1'b0;
		shift_reg = 8'd0;
		package_reg = 28'd0;
		counter = 6'd0;
		det_X = 1'b0;
		det_Y = 1'b0;
		det_Z = 1'b0;
	end else begin
		if (i_ena) begin
			
			/* Create data-flow */
			case ({i_head, i_one, i_zero})
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
			
			//if ((det_X || det_Y) || det_Z) 
			//	counter <= 6'd0;
			
			/* Try to latch correct package on next preamble */
			if (i_head & (counter == 6'd54)) begin
				for (i = 0; i < 28; i = i+1) begin
					o_package[i] <= package_reg[i<<1];
				end
				o_ready <= 1'b1;
			end else
				o_ready <= 1'b0;
			
			/* Decode and create audio-block */
			if ((shift_reg[1:0] == pattern_0) || (shift_reg[1:0] == ~pattern_0)) begin
				package_reg <= {package_reg[54:0], 1'b0};
			end
			if ((shift_reg[1:0] == pattern_1) || (shift_reg[1:0] == ~pattern_1)) begin
				package_reg <= {package_reg[54:0], 1'b1};
			end
			
			/* Restart packager module */
			// i_HEAD IS A WIRE !
			if (((det_X || det_Y) || det_Z) || (i_head & (counter == 6'd54))) counter <= 6'd0;	
			else if (((shift_reg[1:0] == pattern_0) || (shift_reg[1:0] == ~pattern_0)) || ((shift_reg[1:0] == pattern_1) || (shift_reg[1:0] == ~pattern_1))) counter <= counter + 1'b1;
			
		end
	end
end

endmodule
