module data_mem_1( 
	input logic [31:0] address, 
	input logic [31:0] WriteData, 
	input MemWrite, 
	input MemRead, 
	input clk, 
	output logic [31:0] ReadData 
); 

//data mem has capacity for 2^32 32-bit entries. 

logic [31:0] Mem[0:4294967295];  


initial begin 
	$readmemh("Datamem_0.txt", Mem); 
end 

//we use byte addressing hence 2 LSB is ignored 
always_ff @ (posedge clock) begin 
	if (MemWrite) begin 
		Mem[address>>2] <= WriteData; 

	end 
end 

always_ff @(negedge clock) begin 
	if (MemRead) begin 
		ReadData <= Mem[address>>2]; 
	end 
end  

endmodule 

 
 

 
