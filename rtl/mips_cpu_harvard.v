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
    stall = 0;
  end

  logic[31:0] PCin;
  logic stall;

  always_comb
  begin
    if ((opcode == 6'h28 | opcode == 6'h29))
    begin
      stall = 1;
    end
    else
    begin
      stall = 0;
    end
  end

  always@(posedge clk)
  begin
    if (stall == 1)
    begin
      stall <= 0;
    end
  end


  logic [31:0] prev_instr;
  assign prev_instr = PCin-4;


  // Program counter connection
  PC_1 pc (.PCin(PCin), .clk(clk), .reset(reset),
           .clk_enable(clk_enable), .stall(stall), .prev_instr(prev_instr),
           .PCout(instr_address)
          );

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
  logic [4:0] rt_instr;
  assign opcode = instr_readdata[31:26];
  assign functcode = instr_readdata[5:0];
  assign immediate = instr_readdata[15:0];
  assign shamt = instr_readdata[10:6];
  assign rt_instr = instr_readdata[20:16];

  //Control Unit connection
  logic JR, Jump, MemRead, MemWrite, delay_early;
  logic [1:0] RegDst, RegWrite, HI_write, LO_write;
  logic [2:0] MemtoReg;
  control_unit maincontrol (
                 .JR(JR), .Jump(Jump), .RegWrite(RegWrite), .MemRead(data_read),
                 .MemWrite(data_write), .RegDst(RegDst), .MemtoReg(MemtoReg),
                 .HI_write(HI_write), .LO_write(LO_write), .delay_early(delay_early),
                 .opcode(opcode),
                 .funct(functcode),
                 .rt(rt_instr), .stall(stall)
               );

  //delay slot implementation
  logic delay;
  always_ff@(posedge clk)
  begin
    delay <= delay_early;
  end


  logic [31:0] delay_addr;
  delayslot delayreg (
              .clk(clk), .Branch(Branch), .Jump(Jump), .JR(JR), .branch_address(branch_address),
              .jump_address(jump_address), .PCplus8(PCplus8), .rs_content(rs_content),
              .delay_addr(delay_addr)
            );

  mux32 pcaddr (
          .InputA(PCplus4), .InputB(delay_addr), .CtlSig(delay), .Output(PCin)
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
              .data_address2LSB(data_address[1:0]),
              .ReadData1(rs_content), .ReadData2(rt_content),
              .register_v0(register_v0), .reset(reset)
            );

  //ALU Connection
  logic [31:0] HI, LO;
  logic Branch;
  ALU_2 alu (
          .functcode(functcode), .opcode(opcode), .shamt(shamt),
          .immediate(immediate),.rs_content(rs_content), .rt_content(rt_content), .rt_instr(rt_instr),
          .sig_branch(Branch), .ALU_result(data_address), .HI(HI), .LO(LO)
        );

  //Connection of HI register to ALU
  logic [31:0] HI_reg;
  single_reg HIreg (
               .clk(clk), .RegWrite(HI_write), .reset(reset), .WriteData(HI), .ReadData(HI_reg)
             );

  //Connection of LO register to ALU
  logic [31:0] LO_reg;
  single_reg LOreg (
               .clk(clk), .RegWrite(LO_write), .reset(reset), .WriteData(LO), .ReadData(LO_reg)
             );

  //Connection of select_writedata as input to data mem
  logic[31:0] data_readdelayed;
  always_ff@(posedge clk)
  begin
    data_readdelayed <= selected_readdata;
  end
  select_datawrite selectwrite (
                     .rt_content(rt_content), .data_readdata(data_readdelayed), .opcode(opcode),
                     .data_address2LSB(data_address[1:0]), .data_writedata(data_writedata),
                     .stall(stall)
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

  //Connection of jump_addr
  logic[31:0] jump_address;
  jump_addr jump_addr_mod (
              .instr25_0 (instr_readdata[25:0]), .PC_next31_28(PCplus4[31:28]),
              .jump_address(jump_address)
            );


  //Connection of Data Memory
  // data_mem_1 datamem (
  //              .address(data_address), .WriteData(data_writedata),
  //              .MemWrite(data_write), .MemRead(data_read), .clk(clk),
  //              .ReadData(data_readdata)
  //            );

  //Connection of select_datamem for input to MemtoReg mux
  logic [31:0] selected_readdata;
  select_datamem selectmod (
                   .fullread(data_readdata), .opcode(opcode), .data_address2LSB(data_address[1:0]),
                   .ReadData(selected_readdata)
                 );

  //Connection of Mux between data memory and reg write data
  logic [31:0] PCplus8;
  assign PCplus8 = PCplus4 + 4;
  mux32_5 mux_datamem (
            .InputA(data_address), .InputB(selected_readdata), .InputC(PCplus8),
            .HI_reg(HI_reg), .LO_reg(LO_reg),
            .CtlSig(MemtoReg),
            .Output(write_data)
          );

  initial
  begin
    $monitor("CPU: instruction: %h, PC: %h\n ReadData2:%h data_address:%h data_writedata:%h stall:%b selected_readdata:%h readdelayed:%h data_readdata:%h MemWrite:%b",instr_readdata, instr_address, rt_content, data_address, data_writedata, stall, selected_readdata, data_readdelayed, data_readdata, MemWrite);
  end

endmodule
