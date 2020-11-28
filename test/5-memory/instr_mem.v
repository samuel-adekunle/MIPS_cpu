module instr_mem( 

	input logic [31:0] address, 
	input logic clock, 
	output logic [31:0] instr 
); 

//instr mem has capacity for 2^32 32-bit entries. 
//initialise the content at each address using a text file containing the instructions. 
parameter INSTR_INIT_FILE = "";
reg [31:0] memory [0:4095]; 

// initial begin 
// 	$readmemh(INSTR_INIT_FILE, memory); 
// end 
initial begin
	integer i;
	/* Initialise to zero by default */
	for (i=0; i<4095; i++) begin
		memory[i]=0;
	end
	/* Load contents from file if specified */
	if (INSTR_INIT_FILE != "") begin
		$display("INSTR_MEM : INIT : Loading INSTR contents from %s", INSTR_INIT_FILE);
		$readmemh(INSTR_INIT_FILE, memory);
	end
end
//we use byte addressing hence 2 LSB is ignored 

always_ff @(posedge clock) begin 
	instr <= memory[address>>2]; 
end 

endmodule 

 

