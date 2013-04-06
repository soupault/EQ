// Function : D flip-flop async reset
// Purpose  : for simulating design in ModelSim Web version

module FFE (d, clk, clrn, ena, q);

input d, clk, clrn, ena; 
output reg q;

always @ (posedge clk or negedge clrn)
begin	
	if (~clrn) 
		q <= 1'b0;
	else if (ena)
		q <= d;
end

endmodule
