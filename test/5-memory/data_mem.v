// module data_mem( 
// 	input logic [31:0] address, 
// 	input logic [31:0] WriteData, 
// 	input MemWrite, 
// 	input MemRead, 
// 	input clock, 
// 	output logic [31:0] ReadData 
// ); 

// //small sim of 4096
// parameter DATA_INIT_FILE = "";
// reg [31:0] Mem[0:4095];  

// // initial begin 
// // 	$readmemh(DATA_INIT_FILE, Mem); 
// // end 
// initial begin
// 	integer i;
// 	/* Initialise to zero by default */
// 	for (i=0; i<4096; i++) begin
// 		Mem[i]=0;
// 	end
// 	/* Load contents from file if specified */
// 	if (DATA_INIT_FILE != "") begin
// 		$display("DATA_MEM : INIT : Loading DATA contents from %s", DATA_INIT_FILE);
// 		$readmemh(DATA_INIT_FILE, Mem);
// 	end
// end
// //we use byte addressing hence 2 LSB is ignored 
// always_ff @ (posedge clock) begin 
// 	if (MemWrite) begin 
// 		Mem[address>>2] <= WriteData; 

// 	end 
// end 

// always_ff @(negedge clock) begin 
// 	if (MemRead) begin 
// 		ReadData <= Mem[address>>2]; 
// 	end 
	
// end  

// endmodule 

module data_mem( 
	input logic [31:0] address, 
	input logic [31:0] WriteData, 
	input MemWrite, 
	input MemRead, 
	input clk, 
	output logic [31:0] ReadData 
); 

//data mem has capacity for 4095 32-bit entries. 

logic [31:0] Mem[0:4095];  
parameter DATA_INIT_FILE = "";

initial begin
	integer i;
	/* Initialise to zero by default */
	for (i=0; i<4096; i++) begin
		Mem[i]=0;
	end
	/* Load contents from file if specified */
	if (DATA_INIT_FILE != "") begin
		$display("DATA_MEM : INIT : Loading DATA contents from %s", DATA_INIT_FILE);
		$readmemh(DATA_INIT_FILE, Mem);
	end
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
 

 
