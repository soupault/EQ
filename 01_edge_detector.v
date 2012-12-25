module edge_detector (i_spdif, i_rst_n, i_clk, i_ena, o_zero, o_one, o_head, o_shift_ena);

input wire i_spdif;
input wire i_rst_n;
input wire i_clk;
input wire i_ena;

output reg o_zero;
output reg o_one;
output reg o_head;
output reg o_shift_ena;

wire is_edge;
reg ff_bfr;
reg [4:0] counter;

assign is_edge = ff_bfr ^ i_spdif; // xor

always @(posedge i_clk or negedge i_rst_n)
begin
	if (~i_rst_n) begin
		counter <= 5'd0;
		o_zero <= 1'b0;
		o_one <= 1'b0;
		o_head <= 1'b0;
		o_shift_ena <= 1'b0;
	end else begin
		if (i_ena) begin
			ff_bfr <= i_spdif;
			if (is_edge) begin
				counter <= 0;
				o_shift_ena <= 1'b1;
				if ((counter >= 5'd3) | (counter <= 5'd7))
					o_zero <= 1'b1;
				else if ((counter >= 5'd9) | (counter <= 5'd13))
					o_one <= 1'b1;
				else if ((counter >= 5'd15) | (counter <= 5'd19))
					o_head <= 1'b1;
				// else
			end else begin
				counter <= counter + 1'b1;
				o_zero <= 1'b0;
				o_one <= 1'b0;
				o_head <= 1'b0;
				o_shift_ena <= 1'b0;
			end
		end
	end
end

endmodule
