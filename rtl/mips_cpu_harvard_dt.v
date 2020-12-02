// module mips_cpu_harvard_dt( 
//    	/* Standard signals */ 
// 	input logic     clk, 
//   	input logic     reset, 
// 	output logic    active, 
//  	output logic [31:0] register_v0, 

//     	/* New clock enable. See below. */ 
//   	input logic     clk_enable, 
 
//     	/* Combinatorial read access to instructions */ 
//   	output logic[31:0]  instr_address, 
// 	input logic[31:0]   instr_readdata, 

// 	/* Combinatorial read and single-cycle write access to instructions */ 
//   	output logic[31:0]  data_address, 
// 	output logic        data_write,
//   	output logic        data_read, 
//   	output logic[31:0]  data_writedata, 
//  	input logic[31:0]  data_readdata 
// ); 

// 	/* Using an enum to define constants */
//     	typedef enum logic[5:0] {
//         	OPCODE_ADDIU = 6'b001001,
// 			OPCODE_RTYPE = 6'b000000,
// 			OPCODE_LW = 6'b100011,
// 			OPCODE_SW = 6'b101011,

// 			OPCODE_ANDI = 6'b001100,
// 			OPCODE_ORI = 6'b001101,
// 			OPCODE_XORI = 6'b001110,
// 			OPCODE_BEQ = 6'b000100,
// 			OPCODE_BEQZ = 6'b000001,
// 			OPCODE_BGTZ = 6'b000111,
// 			OPCODE_BLEZ = 6'b000110,
// 			OPCODE_BNE = 6'b000101,

// 			OPCODE_J = 6'b000010,
// 			OPCODE_JAL = 6'b000011,

// 			OPCODE_LB = 6'b100000,
// 			OPCODE_LBU = 6'b100100,
// 			OPCODE_LH = 6'b100001,
// 			OPCODE_LHU = 6'b100101,
// 			OPCODE_LUI = 6'b001111,
// 			OPCODE_LWL = 6'b100010,
// 			OPCODE_LWR = 6'b100110,

// 			OPCODE_SB = 6'b101000,
// 			OPCODE_SH = 6'b101001,

// 			OPCODE_SLTI = 6'b001010,
// 			OPCODE_SLTIU = 6'b001011,
//     	} opcode_t;

// 	typedef enum logic[5:0] {
// 			OPCODE_ADDU = 6'b100001,
// 			OPCODE_SUBU = 6'b100001,
// 			OPCODE_DIV = 6'b011010,
// 			OPCODE_DIVU = 6'b011011,
// 			OPCODE_MULT = 6'b011000,
// 			OPCODE_MULTU = 6'b011001,

// 			OPCODE_AND = 6'b100100,
// 			OPCODE_OR = 6'b100101,
// 			OPCODE_XOR = 6'b100110,
// 			OPCODE_JALR = 6'b001001,
//         	OPCODE_JR = 6'b001000,
// 			OPCODE_MTHI = 6'b010001,
// 			OPCODE_MTLO = 6'b010011,

// 			OPCODE_SLL = 6'b000000,
// 			OPCODE_SLLV = 6'b000100,
// 			OPCODE_SLT = 6'b011010,
// 			OPCODE_SLTU = 6'b101011,
// 			OPCODE_SRA = 6'b000011,
// 			OPCODE_SRAV = 6'b000111,
// 			OPCODE_SRL = 6'b000010,
// 			OPCODE_SRLV = 6'b000110
//     	} functcode_t; 

// 	/* Another enum to define 6 CPU states. */
//     	typedef enum logic[2:0] {
//         	IF = 3'd0,
//         	ID = 3'd1,
// 			EX = 3'd2,
// 			MEM = 3'd3,
// 			WB = 3'd4,
//         	HALTED = 3'd5
//     	} state_t;

// 	logic[31:0] pc, pc_next;
//     	logic[31:0] acc; //EDIT THIS TO 32 REGISTERS

//     	logic[31:0] instr;
//     	opcode_t instr_opcode;
// 	functcode_t instr_functcode;
//     	logic[15:0] instr_offset;    

//     	logic[2:0] state;

// 	// Decide what address to put out on the bus, and whether to write
//     	assign instr_address = (state==IF) ? pc : instr_constant;
//     	assign write = state==EXEC_INSTR ? instr_opcode==OPCODE_SW : 0; // Write
//     	assign read = (state==FETCH_INSTR) ? 1 : (instr_opcode==OPCODE_LW || instr_opcode==OPCODE_ADDIU || instr_opcode==OPCODE_ADDU || instr_opcode==OPCODE_AND || instr_opcode==OPCODE_ANDI); // Read
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
//             $display("CPU : INFO  : Fetching, address=%-h.", pc);
//             instr <= instr_readdata;
//             state <= ID;
//         end
//         else if (state==ID) begin
//             $display("CPU : INFO  : Decoding, opcode=%h, acc=%h, imm=%h, readdata=%x", instr_opcode, acc, instr_constant, readdata);
//             case(instr_opcode)
//                 OPCODE_RTYPE: begin
//                     acc <= readdata;
//                     state <= EX;
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
// 	else if (state==EX) begin
// 	     $display("CPU : INFO  : Executing, opcode=%h, acc=%h, imm=%h, readdata=%x", instr_opcode, acc, instr_constant, readdata);
// 	     case(instr_opcode) 
// 		OPCODE_ADDU: begin
// 			writedata <= ReadData1 + ReadData2;
// 			state <= IF; 
// 			pc <= pc_increment;
// 		end
// 		OPCODE_AND: begin
// 			writedata <= ReadData1 & ReadData2;
// 			state <= IF;
// 			pc <= pc_increment;
// 		end
		

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
// endmodule


