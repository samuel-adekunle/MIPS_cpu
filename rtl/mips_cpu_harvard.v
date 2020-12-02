module mips_cpu_harvard( 
   	/* Standard signals */ 
	input logic     clk, 
  	input logic     reset, 
	output logic    active, 
 	output logic [31:0] register_v0, 

    	/* New clock enable. See below. */ 
  	input logic     clk_enable, 
 
    	/* Combinatorial read access to instructions */ 
  	output logic[31:0]  instr_address, 
	input logic[31:0]   instr_readdata, 

	/* Combinatorial read and single-cycle write access to instructions */ 
  	output logic[31:0]  data_address, 
	output logic        data_write,
  	output logic        data_read, 
  	output logic[31:0]  data_writedata, 
 	input logic[31:0]  data_readdata 
); 
	logic[31:0] PC_next; 
	// Program counter connection
	PC_1 pc (.PCin(instr_address), .clk(clk), .reset(reset), 
		.clk_enable(clk_enable),.PC_out(PC_next));
	
	// Instruction Memory connection
	logic [31:0] instr;
	instr_mem_1 instrmem (.address(instr_address), .clk(clk), .instr(instr));
	
	// Parse instruction
	logic [5:0] functcode;
	logic [4:0] shamt;
	logic [15:0] immediate;
	logic [5:0] opcode;
	assign opcode = instr[31:26]; 
	assign functcode = instr[5:0]; 
	assign immediate = instr[15:0]; 
	assign shamt = instr[10:6];
	
	//Control Unit connection
	logic JR, Jump, RegWrite, MemRead, MemWrite, RegDst, Branch;
	control_unit maincontrol (
		.JR(JR), .Jump(Jump), .RegWrite(RegWrite), .MemRead(MemRead), 
		.MemWrite(Mem_Write), .RegDst(RegDst), .Branch(Branch), 
		.opcode(instr[31:26]),
		.funct(instr[5:0])
	);

	//Mux5 between instr_mem and reg file
	logic [4:0] WriteReg;
	mux5 mux_reg (
		.inst20_16(instr[20:16]), .inst15_11(instr[15:11]), .RegDst(RegDst),
		.WriteReg(WriteReg)
	);

	// Registers contents
	logic [31:0] write_data, rs_content, rt_content;
	//Registers Connection
	Registers regfile (
		.clk(clk), .RegWrite(RegWrite),
		.ReadReg1(instr[25:21]), .ReadReg2(instr[20:16]), 
		.WriteReg(WriteReg), .WriteData(write_data), 
		.ReadData1(rs_content), .ReadData2(rt_content),
		.register_v0(register_v0)
	);
	
	//ALU Connection 
	logic [31:0] HI, LO; 
	ALU_2 alu (
		.functcode(functcode), .opcode(opcode), .shamt(shamt),
		.immediate(immediate), .rs_content(rs_content), .rt_content(rt_content),
		.sig_branch(Branch), .ALU_result(data_address), .HI(HI), .LO(LO)
	);
	
	//Connection of Sign Extend
	logic [31:0] Extend32; 
	SignExtend sign_ext (
		.instr15_0(immediate), .Extend32(Extend32)
	); 
	
	//Connection of Shift Left 2
	logic[31:0] extendImm;
	ShiftLeft2 shift2 (
		.ShiftIn(Extend32), .ShiftOut(extendImm)
	);
	
	//Connection of Add_ALU 
	logic [31:0] branch_address; 
	Add_ALU add_alu (
		.PCplus4(PC_next), .extendImm(extendImm), 
		.Add_ALUresult(branch_address)
	);

	//Connection of Mux for branch
	logic [31:0] add_alu_res;
	mux32 mux_branch (
		.InputA(PC_next), .InputB(branch_address), .CtlSig(Branch), 
		.Output(add_alu_res)
	);
	
	//GET JUMP ADDRESSS 

	//Connection of Mux for Jump 
	logic [31:0] mux_jump_res;
	mux32 mux_jump (
		.InputA(add_alu_res), .InputB(jump_address), .CtlSig(Jump), 
		.Output(mux_jump_res)
	);
	
	//Connection of Mux for JR
	mux32 mux_JR (
		.InputA(mux_jump_res), .InputB(rs_content), .CtlSig(JR), 
		.Output(instr_address)
	);

	//Connection of Data Memory
	data_mem_1 datamem (
		.address(data_address), .WriteData(data_writedata), 
		.MemWrite(data_write), .MemRead(data_read), .clk(clk), 
		.ReadData(data_readdata)
	); 

	//Connection of Mux between data memory and reg write data
	mux32 mux_datamem (
		.InputA(data_address), .InputB(data_readdata), .CtlSig(MemtoReg), 
		.Output(write_data)
	);
				
	
	
//	initial begin
//		$monitor("instruction: %32b, PC: %32b\n",
//		instruction, PC);
//	end
	
endmodule

