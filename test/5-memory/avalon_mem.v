 module avalon_mem(  ///idk need to understand properly 
    input logic[31:0] address,
    input logic write,
    input logic read,
    output logic waitrequest,
    input logic[31:0] writedata,
    input logic[3:0] byteenable,
    output logic[31:0] readdata
); 
parameter INSTR_INIT_FILE = "test_load.txt";
parameter BRANCH_JUMP_INIT_FILE = "test_load.txt";
parameter DATA_INIT_FILE = "test_load.txt";
parameter [31:0] rst = 32'hbfc00000; 
parameter [31:0] branch_max = 32'h0007fff<<2; 
parameter [31:0] branch_min = 32'hffff8000<<2; 
parameter [31:0] max_jump_addr = 32'hb3fffffc; 
parameter reset_offset = 60;
parameter no_offset = 20; //11-20 jump backwards //same addrs
parameter branch_back_offset = 21; //21-30 branch backwards maximum 
parameter branch_forward_offset = 31; //31-40 branch forwards maximum
parameter jump_forward_offset = 41; //41-50 jump maximum
//let 40 be the reset vector. around it can be other locations
//instr mem has capacity for 4096 32-bit entries. 
//initialise the content at each address using a text file containing the instructions. 
logic [31:0] temp_read = 0;
logic [31:0] temp_write = 0;
logic [31:0] memory [0:1023]; 
// initial begin 
// 	$readmemh(INSTR_INIT_FILE, memory); 
// end 
initial begin
	integer i;
	/* Initialise to zero by default */
	for (i=0; i<1024; i++) begin
		memory[i]=0;
	end
	/* Load contents from file if specified */
	if (DATA_INIT_FILE != "") begin
		$display("AVALON : INIT : Loading DATA contents from %s", DATA_INIT_FILE);
		$readmemh(DATA_INIT_FILE, memory,1, 10);
	end
	if (INSTR_INIT_FILE != "") begin
		$display("AVALON : INIT : Loading INSTR contents from %s", INSTR_INIT_FILE);
		$readmemh(INSTR_INIT_FILE, memory,reset_offset);
	end
	if (BRANCH_JUMP_INIT_FILE != "") begin
		$display("AVALON : INIT : Loading BRANCH/JUMP contents from %s", BRANCH_JUMP_INIT_FILE);
		$readmemh(BRANCH_JUMP_INIT_FILE, memory,11, 50);
	end

end
integer x;
//we use byte addressing hence 2 LSB is ignored 
//combi read path
always @(*) begin 
	waitrequest = 0;
	if (read) begin 
		if ((address>>2) <= no_offset)begin 
			//jump back to 11-20 or data 0-10
			temp_read = memory[address>>2]; 
		end
		else if (address>=(rst+(branch_min))&&address<(rst+branch_min+40))begin
			x = ((address-(rst+branch_min))>>2)+branch_back_offset;
			temp_read = memory[x];
		end
		else if (address>=rst+branch_max && address <= rst+branch_max+40) begin 
			x = ((address-rst-branch_max)>>2)+branch_forward_offset;
			//branch forwards to addresses 32'hbfc1fffc + 10 addr
			temp_read= memory[x]; 
		end
		else if (address>=max_jump_addr&& address<=max_jump_addr+40) begin 
			//jump forwards to addresses 32'hc0000000 + 10 addr
			x = ((address-max_jump_addr)>>2)+jump_forward_offset;
			temp_read = memory[x]; 
		end
		else begin
			temp_read = memory[((address-rst)>>2)+reset_offset];
		end
		readdata[31:24] = byteenable[3] ? temp_read[31:24] : 8'b0;
		readdata[23:16] = byteenable[2] ? temp_read[23:16] : 8'b0;
		readdata[15:8] = byteenable[1] ? temp_read[15:8] : 8'b0;
		readdata[7:0] = byteenable[0] ? temp_read[7:0] : 8'b0;
		

	end
	if (write) begin 
		if ((address>>2) <= no_offset)begin 
			//jump back to 11-20 or data 0-10
			temp_read = memory[address>>2];
			//sb
			temp_write[31:24] = byteenable[3] ? temp_read[31:24] : writedata[31:24];
			temp_write[23:16] = byteenable[2] ? temp_read[23:16] : writedata[23:16];
			temp_write[15:8] = byteenable[1] ? temp_read[15:8] : writedata[15:8];
			temp_write[7:0] = byteenable[0] ? temp_read[7:0] : writedata[7:0];
			memory[address>>2] = temp_write; 
		end
		else if (address>=(rst+(branch_min))&&address<(rst+branch_min+40))begin
			x = ((address-(rst+branch_min))>>2)+branch_back_offset;
			memory[x] = writedata;
		end
		else if (address>=rst+branch_max && address <= rst+branch_max+40) begin 
			x = ((address-rst-branch_max)>>2)+branch_forward_offset;
			//branch forwards to addresses 32'hbfc1fffc + 10 addr
			memory[x] = writedata; 
		end
		else if (address>=max_jump_addr&& address<=max_jump_addr+40) begin 
			//jump forwards to addresses 32'hc0000000 + 10 addr
			x = ((address-max_jump_addr)>>2)+jump_forward_offset;
			memory[x] = writedata; 
		end
		else begin
			memory[((address-rst)>>2)+reset_offset] = writedata;
		end
	end
end 

endmodule 
      