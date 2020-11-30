module instr_mem_1 ( 

	input logic [31:0] address, 
	input logic clock, 
	output logic [31:0] instr 
); 

//instr mem has capacity for 2^32 32-bit entries. 
//initialise the content at each address using a text file containing the instructions. 

logic [31:0] memory [0:4294967295]; 

initial begin 
	$readmemh("instructions_0.txt", memory); 
end 

//we use byte addressing hence 2 LSB is ignored 

always_ff @( posedge clock) begin 
	instr <= memory[address>>2]; 
	end 

endmodule 

 

