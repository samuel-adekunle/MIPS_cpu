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
<<<<<<< HEAD
 always @(posedge clk) begin
	active <= 1'b1;
	register_v0 <= 32'b0;	 
 end
 
// 	/* Using an enum to define constants */
//     	typedef enum logic[5:0] {
//         	OPCODE_ADDIU = 6'b001001,
// 		OPCODE_RTYPE = 6'b000000,
// 		OPCODE_LW = 6'b100011,
// 		OPCODE_SW = 6'b101011
//     	} opcode_t;

// 	typedef enum logic[5:0] {
//         	OPCODE_JR = 6'b001000
//     	} functcode_t; 

// 	/* Another enum to define 6 CPU states. */
//     	typedef enum logic[2:0] {
//         	IF = 3'd0,
//         	ID = 3'd1,
// 		EX = 3'd2,
// 		MEM = 3'd3,
// 		WB = 3'd4,
//         	HALTED = 3'd5
//     	} state_t;
	
// 	//Registers
// 	logic[31:0] pc, pc_next;
//     	logic[31:0] register [0:31]; //register file with 32 32-bit registers
// 	logic[4:0] ReadReg1;
// 	logic[4:0] ReadReg2;
// 	logic[4:0] WriteReg;

//     	logic[31:0] instr;
//     	opcode_t instr_opcode;
// 	functcode_t instr_functcode;
//     	logic[15:0] instr_offset;    

//     	logic[2:0] state;

// 	// Decide what address to put out on the bus, and whether to write
//     	assign instr_address = (state==IF) ? pc : instr_constant;
//     	assign write = state==EXEC_INSTR ? instr_opcode==OPCODE_STO : 0;
//     	assign read = (state==FETCH_INSTR) ? 1 : (instr_opcode==OPCODE_LDA || instr_opcode==OPCODE_ADD  || instr_opcode==OPCODE_SUB );
//     	assign writedata = acc;

// 	// Break-down the instruction into fields
// 	// these are just wires for our convenience
// 	assign instr_opcode = instr[31:26];
// 	assign instr_functcode = instr[5:0];

// 	// This is used in many places, as most instructions go forwards by 1 step (4 bytes)
//     	wire[31:0] pc_increment;
//     	assign pc_increment = pc + 4;

// 	//at start
// 	initial begin
//         	state = HALTED;
//         	active = 0;
//     	end

// 	/* Main CPU sequential update logic. Where combinational logic is simple, it
//         has been incorporated directly here, rather than splitting it into another
//         block.
//         Note: this is always rather than always_ff due to limitations in the verilog
//         simulator, which can't deal with $display in always_ff blocks.
//     */
//     always @(posedge clk) begin
//         if (reset) begin
//             $display("CPU : INFO  : Resetting.");
//             state <= IF;
//             pc <= 0;
//             register_v0 <= 0;
//             active <= 1;
//         end
//         else if (state==IF) begin
//             $display("CPU : INFO  : Fetching, address=%h.", pc);
//             instr <= instr_readdata;
//             state <= ID;
//         end
//         else if (state==ID) begin
//             $display("CPU : INFO  : Decoding, opcode=%h, acc=%h, imm=%h, readdata=%x", instr_opcode, acc, instr_constant, readdata);
//             case(instr_opcode)
//                 OPCODE_ADDIU: begin
//                     acc <= readdata;
//                     pc <= pc_increment;
//                     state <= FETCH_INSTR;
//                 end
//                 OPCODE_LW: begin
//                     pc <= pc_increment;
//                     state <= FETCH_INSTR;
//                 end
//                 OPCODE_SW: begin
//                     acc <= acc + readdata;
//                     pc <= pc_increment;
//                     state <= FETCH_INSTR;
//                 end
// 		//R-type instructions 
// 		OPCODE_RTYPE: begin
// 		    case(instr_functcode) 
// 			OPCODE_JR: begin
// 			    //SOMETHING
// 			end
// 		    endcase
//             endcase
//         end
// 	else if (state==EX) 

// 	else if (state==MEM) 

// 	else if (state==WB)
//         else if (state==HALTED) begin
//             // do nothing
//         end
//         else begin
//             $display("CPU : ERROR : Processor in unexpected state %b", state);
//             $finish;
//         end
//     end
endmodule
=======

	initial begin 
		active = 0; 
	end

	always_ff@(posedge clk) begin
		if (reset) begin
			active <= 1'b1;
		end
		if (instr_address==0) begin
			active <= 1'b0;
		end 

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
	logic JR, Jump, RegWrite, MemRead, MemWrite, RegDst, Branch, MemtoReg;
	control_unit maincontrol (
		.JR(JR), .Jump(Jump), .RegWrite(RegWrite), .MemRead(MemRead), 
		.MemWrite(Mem_Write), .RegDst(RegDst), .MemtoReg(MemtoReg),
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
	logic Branch; 
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
	
	//Connection of jump_addr
	logic[31:0] jump_address;
	jump_addr jump_addr_mod (
		.instr25_0 (instr[25:0]), .PC_next31_28(PC_next[31:28]), 
		.jump_address(jump_address)
	);

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

>>>>>>> a18d4cdb8e82c5744bfbb55d1f08f348b88aea89
