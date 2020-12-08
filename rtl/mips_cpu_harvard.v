// `include "rtl/PC_1.v"
// `include "rtl/instr_mem_1.v"
// `include "rtl/control_unit.v"
// `include "rtl/mux5.v"
// `include "rtl/mux32.v"
// `include "rtl/Registers.v"
// `include "rtl/ALU_2.v"
// `include "rtl/SignExtend.v"
// `include "rtl/ShiftLeft2.v"
// `include "rtl/Add_ALU.v"
// `include "rtl/jump_addr.v"
// `include "rtl/data_mem_1.v"

module mips_cpu_harvard(
    /* Standard signals */
    input logic         clk,
    input logic         reset,
    output logic        active,
    output logic[31:0]  register_v0,

    /* Clock enable signal */
    input logic         clk_enable,

    /* Combinatorial read access to instructions */
    output logic[31:0]  instr_address,
    input logic[31:0]   instr_readdata,

    /* Combinatorial read and single-cycle write access to instructions */
    output logic[31:0]  data_address,
    output logic        data_write,
    output logic        data_read,
    output logic[31:0]  data_writedata,
    input logic[31:0]   data_readdata
  );

  initial
  begin
    active = 0;
  end

  logic[31:0] PCin;
  // Program counter connection
  PC_1 pc (.PCin(PCin), .clk(clk), .reset(reset),
           .clk_enable(clk_enable),.PCout(instr_address));

  //add4 connection
  logic[31:0] PCplus4;
  add4 adder(.PC(instr_address), .PCplus4(PCplus4)); 

  always_ff@(posedge clk)
  begin
    if (reset)
    begin
      active <= 1'b1;
    end
    if (instr_address==0)
    begin
      active <= 1'b0;
    end
  end

  // Instruction Memory connection
  //instr_mem_1 instrmem (.address(instr_address), .clk(clk), .instr(instr_readdata));

  // Parse instruction
  logic [5:0] functcode;
  logic [4:0] shamt;
  logic [15:0] immediate;
  logic [5:0] opcode;
  assign opcode = instr_readdata[31:26];
  assign functcode = instr_readdata[5:0];
  assign immediate = instr_readdata[15:0];
  assign shamt = instr_readdata[10:6];

  //Control Unit connection
  logic JR, Jump, RegWrite, MemRead, MemWrite, RegDst, MemtoReg;
  control_unit maincontrol (
                 .JR(JR), .Jump(Jump), .RegWrite(RegWrite), .MemRead(MemRead),
                 .MemWrite(MemWrite), .RegDst(RegDst), .MemtoReg(MemtoReg),
                 .opcode(opcode),
                 .funct(functcode)
               );

  //Mux5 between instr_mem and reg file
  logic [4:0] WriteReg;
  mux5 mux_reg (
         .inst20_16(instr_readdata[20:16]), .inst15_11(instr_readdata[15:11]), 
	 .RegDst(RegDst),
         .WriteReg(WriteReg)
       );

  // Registers contents
  logic [31:0] write_data, rs_content, rt_content;
  //Registers Connection
  Registers regfile (
              .clk(clk), .RegWrite(RegWrite),
              .ReadReg1(instr_readdata[25:21]), .ReadReg2(instr_readdata[20:16]),
              .WriteReg(WriteReg), .WriteData(write_data),
              .ReadData1(rs_content), .ReadData2(rt_content),
              .register_v0(register_v0), .reset(reset)
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
            .PCplus4(PCplus4), .extendImm(extendImm),
            .Add_ALUresult(branch_address)
          );

  //Connection of Mux for branch
  logic [31:0] add_alu_res;
  mux32 mux_branch (
          .InputA(PCplus4), .InputB(branch_address), .CtlSig(Branch),
          .Output(add_alu_res)
        );

  //Connection of jump_addr
  logic[31:0] jump_address;
  jump_addr jump_addr_mod (
              .instr25_0 (instr_readdata[25:0]), .PC_next31_28(PCplus4[31:28]),
              .jump_address(jump_address)
            );

  //Connection of Mux for Jump
  logic [31:0] mux_jump_res;
  mux32 mux_jump (
          .InputA(PCplus4), .InputB(jump_address), .CtlSig(Jump),
          .Output(mux_jump_res)
        );

  //Connection of Mux for JR
  mux32 mux_JR (
          .InputA(mux_jump_res), .InputB(rs_content), .CtlSig(JR),
          .Output(PCin)
        );

  //Connection of Data Memory
  // data_mem_1 datamem (
  //              .address(data_address), .WriteData(data_writedata),
  //              .MemWrite(data_write), .MemRead(data_read), .clk(clk),
  //              .ReadData(data_readdata)
  //            );

  //Connection of Mux between data memory and reg write data
  mux32 mux_datamem (
          .InputA(data_address), .InputB(data_readdata), .CtlSig(MemtoReg),
          .Output(write_data)
        );

  initial
  begin
    $monitor("instruction: %32b, PCout: %h PCin: %h",instr_readdata, instr_address, PCin);
  end

endmodule

