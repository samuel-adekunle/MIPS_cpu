 module instr_mem( 
	input logic [31:0] address, 
	input logic clk, 
	output logic [31:0] instr 
); 
parameter INSTR_INIT_FILE = "test_load.txt";
parameter [31:0] rst = 32'hbfc00000; 
parameter offset = 40;
//let 40 be the reset vector. around it can be other locations
//instr mem has capacity for 4096 32-bit entries. 
//initialise the content at each address using a text file containing the instructions. 

logic [31:0] memory [0:4095]; 
//keep 0 as 0 but the rest offset from BFC

// initial begin 
// 	$readmemh(INSTR_INIT_FILE, memory); 
// end 
initial begin
	integer i;
	/* Initialise to zero by default */
	for (i=0; i<4096; i++) begin
		memory[i]=0;
	end
	/* Load contents from file if specified */
	if (INSTR_INIT_FILE != "") begin
		$display("INSTR_MEM : INIT : Loading INSTR contents from %s", INSTR_INIT_FILE);
		$readmemh(INSTR_INIT_FILE, memory,offset);
	end
end

//we use byte addressing hence 2 LSB is ignored 
//combi read path
always_comb begin 
	if (address!=0) begin
		instr = memory[((address-rst)>>2)+40]; 
	end
	else begin
		instr = memory[address>>2];
	end
end 

endmodule 