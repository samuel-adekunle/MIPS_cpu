module hi_lo ( 
	input logic clk,  
	input logic RegWrite,  //write_en
	input logic reset,
	//1-bit input(2 regs)
	input logic [1:0] ReadReg,   //which to read
	input logic [1:0] WriteReg,  //which to write
	//WriteData: 32-bit input to be written into a register 
	input logic [31:0] WriteData,
	//32-bit data read from registers selected by ReadReg, WriteReg 
	output logic [31:0] ReadData,  
); 

//2 regs. 0 LO, 1 HI
logic [31:0] register [0:1]; 
//for loop 
integer i; 

//output. 32-bit data read from registers selected by ReadReg, WriteReg 
assign ReadData = register[ReadReg]; 
//at rising edge of clk, if RegWrite_en is 1, write WriteData into register selected by WriteReg 
always_ff @(posedge clk) begin 
	if (reset) begin
		for (i = 0; i < 2; i = i + 1) begin
  			register[i] <= 0;
		end
	end
	if (RegWrite) begin 
	register[WriteReg] <= WriteData; 
	end  
end

endmodule 

 
 
