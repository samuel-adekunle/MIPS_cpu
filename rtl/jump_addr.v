module jump_addr ( 
	input logic [25:0] instr25_0, 
	input logic [3:0] PC_next31_28, 
	output logic [31:0] jump_address 
); 

logic [27:0] shifted;

always_comb begin
	shifted = instr25_0 << 2; 
	jump_address = {PC_next31_28[3:0], shifted[27:0]};
end 


endmodule 
