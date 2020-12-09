 module instr_mem( 
	input logic [31:0] address, 
	input logic clk, 
	output logic [31:0] instr 
); 
parameter INSTR_INIT_FILE = "test_load.txt";
parameter BRANCH_JUMP_INIT_FILE = "test_loadk.txt";
parameter [31:0] rst = 32'hbfc00000; 
parameter [31:0] branch_max = 32'h0007fff<<2; 
parameter [31:0] branch_min = 32'hffff8000<<2; 
parameter [31:0] max_jump_addr = 32'hc0000000; 
parameter reset_offset = 60;
parameter no_offset = 20; //11-20 jump backwards //same addrs
parameter branch_back_offset = 21; //21-30 branch backwards maximum 
parameter branch_forward_offset = 31; //31-40 branch forwards maximum
parameter jump_forward_offset = 41; //41-50 jump maximum
//let 40 be the reset vector. around it can be other locations
//instr mem has capacity for 4096 32-bit entries. 
//initialise the content at each address using a text file containing the instructions. 

logic [31:0] memory [0:4095]; 
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
		$readmemh(INSTR_INIT_FILE, memory,reset_offset);
	end
	if (BRANCH_JUMP_INIT_FILE != "") begin
		$display("INSTR_MEM : INIT : Loading BRANCH/JUMP contents from %s", BRANCH_JUMP_INIT_FILE);
		$readmemh(BRANCH_JUMP_INIT_FILE, memory,11, 50);
	end
end
integer x;
//we use byte addressing hence 2 LSB is ignored 
//combi read path
always @(*) begin 
	//$display("%h becomes %h", rst+branch_min,(rst-branch_min));
	if ((address>>2) <= no_offset)begin 
		//jump back to 11-20 or data 0-10
		instr = memory[address>>2]; 
	end
	else if (address>=(rst+(branch_min))&&address<(rst+branch_min+40))begin
		x = ((address-(rst+branch_min))>>2)+branch_back_offset;
		instr = memory[x];
	end
	else if (address>=rst+branch_max && address <= rst+branch_max+40) begin 
		x = ((address-rst-branch_max)>>2)+branch_forward_offset;
		//branch forwards to addresses 32'hbfc1fffc + 10 addr
		instr = memory[x]; 
	end
	else if (address>=max_jump_addr) begin 
		//jump forwards to addresses 32'hc0000000 + 10 addr
		x = ((address-max_jump_addr)>>2)+jump_forward_offset;
		instr = memory[x]; 
	end
	// else if (address == 32'hffffffff){ //attempt to jump here maybe?
	// 	instr = //load something into v0?
	// }
	else begin
		instr = memory[((address-rst)>>2)+reset_offset];
	end
end 

endmodule 
      