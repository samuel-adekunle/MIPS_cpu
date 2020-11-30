module data_mem_1( 
	input logic [31:0] address, 
	input logic [31:0] WriteData, 
	input MemWrite, 
	input MemRead, 
	input clk, 
	output logic [31:0] ReadData 
); 

//data mem has capacity for 4095 32-bit entries. 

logic [31:0] Mem[0:4095];  


initial begin 
	$readmemh("Datamem_0.txt", Mem); 
end 

//we use byte addressing hence 2 LSB is ignored 
//single-cycle write 
always_ff @ (posedge clk) begin 
	if (MemWrite) begin 
		Mem[address>>2] <= WriteData; 
	end 
end 

//combinatorial read path 
always_comb begin 
	if (MemRead) begin 
		ReadData = Mem[address>>2]; 
	end 
end  

endmodule 

 
 

 
