module SignExtend ( 
	input logic [15:0] instr15_0, 
	output logic [31:0] Extend32 
); 

 
assign Extend32[31:0] = { {16{instr15_0[15]}}, instr15_0[15:0]};   

endmodule 
