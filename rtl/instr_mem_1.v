module instr_mem_1 ( 

	input logic [31:0] address, 
	input logic clk, 
	output logic [31:0] instr 
); 

//instr mem has capacity for 4096 32-bit entries. 
//initialise the content at each address using a text file containing the instructions. 

logic [31:0] memory [0:4095]; 

initial begin 
	$readmemh("instructions_0.txt", memory); 
end 

//we use byte addressing hence 2 LSB is ignored 
//combi read path
always_comb begin 
	instr = memory[(address-32'hBFC00000)>>2]; 
	end 

endmodule 

 

