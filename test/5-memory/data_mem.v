module data_mem( 
	input logic [31:0] address, 
	input logic [31:0] WriteData, 
	input logic MemWrite, 
	input logic MemRead, 
	input logic [5:0] opcode, 
	input clk, 
	output logic [31:0] ReadData 
); 

//data mem has capacity for 4096 32-bit entries. 
//array can start from 0 
//keep 0 as 0 in both memorys to start with
logic [31:0] Mem[0:4095];  
logic [31:0] fullread; 
parameter DATA_INIT_FILE = "test_load.txt";

initial begin
	integer i;
	/* Initialise to zero by default */
	for (i=0; i<4096; i++) begin
		Mem[i]=0;
	end
	/* Load contents from file if specified */
	if (DATA_INIT_FILE != "") begin
		$display("DATA_MEM : INIT : Loading DATA contents from %s", DATA_INIT_FILE);
		$readmemh(DATA_INIT_FILE, Mem,1);
	end
end

//we use byte addressing hence 2 LSB is ignored 
//single-cycle write 
always_ff @ (posedge clk) begin 
	if (MemWrite) begin 
		Mem[address>>2] <= WriteData; 
	end 
end 


//assign ReadData = MemWrite ? WriteData : Mem[address>>2];
//combinatorial read path 
always@(address, WriteData, MemWrite, MemRead,opcode, clk) begin 
	fullread = Mem[address>>2]; 
	if (MemRead) begin 
		//LW
		if (opcode==6'h23) begin
			ReadData = Mem[address>>2]; 
		end
		//LB
		if (opcode==6'h20) begin
			case(address[1:0])
			3: ReadData = {{24{fullread[31]}}, fullread[31:24]};
			2: ReadData = {{24{fullread[23]}}, fullread[23:16]};
			1: ReadData = {{24{fullread[15]}}, fullread[15:8]};
			0: ReadData = {{24{fullread[7]}}, fullread[7:0]};
			endcase
		end
		//LBU 
		if (opcode==6'h24) begin
			case(address[1:0])
			3: ReadData = {{24{1'b0}}, fullread[31:24]};
			2: ReadData = {{24{1'b0}}, fullread[23:16]};
			1: ReadData = {{24{1'b0}}, fullread[15:8]};
			0: ReadData = {{24{1'b0}}, fullread[7:0]};
			endcase
		end
		//LH
		if (opcode==6'h21) begin
			case(address[0])
			1: ReadData = {{16{fullread[31]}}, fullread[31:16]};
			0: ReadData = {{16{fullread[15]}}, fullread[15:0]};
			endcase
		end
		//LHU
		if (opcode==6'h25) begin
			case(address[0])
			1: ReadData = {{16{1'b0}}, fullread[31:16]};
			0: ReadData = {{16{1'b0}}, fullread[15:0]};
			endcase
		end
	end 
end  

endmodule
 

 
