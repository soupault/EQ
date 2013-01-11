module edge_detector (
	input wire i_spdif,
	input wire i_rst_n,
	input wire i_clk,
//	input wire i_ena,
	
	output reg o_zero,
	output reg o_one,
	output reg o_head,
	output reg o_shift_ena
);

wire is_edge;
reg [2:0] ff_bfr;
reg [4:0] counter;
reg state;

assign is_edge = ff_bfr[2] ^ ff_bfr[1]; // xor

always @(posedge i_clk or negedge i_rst_n)
begin
	if (~i_rst_n) begin
		state <= 1'b0;
		counter <= 5'd0;
		ff_bfr <= 3'd0;
		o_zero <= 1'b0;
		o_one <= 1'b0;
		o_head <= 1'b0;
		o_shift_ena <= 1'b0;
	end else begin
	//	if (i_ena) begin
		/* Metastability */
		ff_bfr[2] <= ff_bfr[1];
		ff_bfr[1] <= ff_bfr[0];
		ff_bfr[0] <= i_spdif;
		
		case(state)
		0: begin
			if (is_edge)
				state <= 1'b1;
		end
		
		1: begin
			if (is_edge) begin
				counter <= 0;
					
				if ((counter >= 5'd3) & (counter <= 5'd7)) begin
					o_shift_ena <= 1'b1;
					o_zero <= 1'b1;
				end else if ((counter >= 5'd9) & (counter <= 5'd13)) begin
					o_shift_ena <= 1'b1;
					o_one <= 1'b1;
				end else if ((counter >= 5'd15) & (counter <= 5'd19)) begin
					o_shift_ena <= 1'b1;
					o_head <= 1'b1;
				end
			end else begin
				counter <= counter + 1'b1;
				o_zero <= 1'b0;
				o_one <= 1'b0;
				o_head <= 1'b0;
				o_shift_ena <= 1'b0;
			end
		end
		endcase
		
	//	end
	end
end

endmodule
