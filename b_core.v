module core (i_spdif, i_rst_n, clk, o_flag, o_enable/*, buffer*/);

input wire i_spdif, i_rst_n, clk;
output reg [2:0] o_flag;
output reg o_enable;

/*output reg [24:0] buffer;*/
reg [24:0] buffer;
reg state;
reg [7:0] counter;

always @(posedge clk or negedge i_rst_n)
begin
	if (~i_rst_n) begin
		o_flag <= 3'b0;
		o_enable <= 1'b0;
		state <= 4'b0;
		buffer <= 25'b0;
		counter <= 8'b0;
	end else begin
		
		case (state)
		// wait for sub-frame preamble
		0: begin
			
			//	X 111111111000000000111000 ff8038 or inv 007fc7
			//	Y 111111111000000111000000 ff81c0 or inv 007e3f
			//	Z 111111111000111000000000 ff8e00 or inv 0071ff 
			// preamble code: bits 10 7 4
			
			case (buffer)
				// X, inv X, Y, inv Y, Z, inv Z
				25'h0ff8038, 25'h1007fc7, 25'h0ff81c0, 25'h1007e3f, 25'h0ff8e00, 25'h10071ff: begin
					o_enable <= 1'b1;
					o_flag <= {buffer[10], buffer[7], buffer[4]};
					state <= 1'b1;
				end
				
				default: begin
					buffer <= (buffer << 1) + i_spdif;
				end
				
			endcase
		end
		
		// do delay until the end of frame
		1: begin
			if (counter == 8'd167) begin // 28 timeslots
				counter <= 8'd0;
				buffer <= 25'b0 + i_spdif;
				o_enable <= 1'b0;
				o_flag <= 3'b0;
				state <= 1'b0;
			end else begin
				counter <= counter + 1'b1;
			end
		end
		
		endcase
	end
end

endmodule
