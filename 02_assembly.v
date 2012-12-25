module assembly (i_zero, i_one, i_head, i_rst_n, i_clk, i_ena, o_package, o_ready);

input wire i_zero;
input wire i_one;
input wire i_head;
input wire i_rst_n;
input wire i_clk;
input wire i_ena;

output reg [// : ] o_package;
output reg o_ready;

reg [7:0] preamble; // 2 bits per char
reg [??] data;

always @(posedge i_clk or negedge i_rst_n)
begin
	if (~i_rst_n) begin
// 
	end else begin
		if (i_ena) begin
			if (i_head) begin
			// reset data_reg
			
			case ({i_head, i_one, i_zero})
				3'b001: begin
					preamble <= {preamble[5:0], 2'b00}
				end
				
				3'b010: begin
					preamble <= {preamble[5:0], 2'b11}
				end
				
				3'b100: begin
					preamble <= {preamble[5:0], 2'b01}
				end
			endcase
			
			case (preamble)
				8'b01011111: begin  // X
					
				end
				
				8'b01001100: begin  // Y
					
				end
				
				8'b01111101: begin  // Z
					
				end
			endcase
			
		end
	end
end

endmodule
