module control_unit (
    output logic JR,
    output logic Jump,
    output logic [1:0] RegWrite,
    output logic MemRead,
    output logic MemWrite,
    output logic [1:0] RegDst, // if this is 0 select rt, 1 select rd, 2 select $ra
    output logic [2:0] MemtoReg, //if this is 2 select PCplus4, 3 select HI, 4 select LO
    output logic [1:0] HI_write,
    output logic [1:0] LO_write,
    output logic delay_early,
    input logic [5:0] opcode,
    input logic [5:0] funct,
    input logic [4:0] rt,
    input logic stall //for sb sh
  );

  always @(opcode, funct, rt, stall)
  begin

    // First, reset all signals
    JR = 1'b0;
    Jump = 1'b0;
    MemRead  = 1'b0;
    MemWrite = 1'b0;
    RegWrite = 2'b0;
    RegDst   = 2'b0;
    MemtoReg = 3'b0;
    delay_early = 1'b0;
    HI_write = 0;
    LO_write = 0;

    // R type
    if(opcode == 6'h0)
    begin
      RegDst = 1;
      //if JR
      //if (funct == 6'h08)
      //begin
      //JR = 1'b1;
      //delay_early = 1'b1;
      //RegWrite = 2'b00;
      //end
      //if MTHI/DIV/DIVU/MULT/MULTU/MTLO/JR
      if (funct == 6'h11||funct == 6'h1a||funct == 6'h1b||funct == 6'h18||funct == 6'h19 || funct == 6'h13 || funct==6'h08)
      begin
        RegWrite = 2'b00;
        if (funct!=6'h13 & funct!=6'h08)
        begin
          HI_write = 2'b11;
        end
        if (funct!=6'h11 & funct!=6'h08)
        begin
          LO_write = 2'b11;
        end
        //JR
        if (funct==6'h08)
        begin
          JR = 1'b1;
          delay_early = 1'b1;
        end
      end
      //if MTLO/DIV/DIVU/MULT/MULTU
      //if (funct == 6'h13||funct == 6'h1a||funct == 6'h1b||funct == 6'h18||funct == 6'h19)
      //begin
      //LO_write = 2'b11;
      //RegWrite = 2'b00;
      //end


      else
      begin
        RegWrite = 2'b11;
      end
      //if JALR
      if (funct == 6'h09)
      begin
        JR = 1'b1;
        MemtoReg = 2;
        delay_early = 1'b1;
      end
      //if MFHI
      if (funct == 6'h10)
      begin
        MemtoReg = 3'b011;
        RegWrite = 2'b11;
      end
      //if MFLO
      if (funct==6'h12)
      begin
        MemtoReg = 3'b100;
        RegWrite = 2'b11;
      end
    end

    // For R-type, all branch instructions, SB, SH and SW don't enter this block
    // For LWL and LWR, we regwrite 01 and 10 instead
    if(opcode != 6'h0 & opcode != 6'h4 & opcode != 6'h5 & opcode != 6'h6 & opcode != 6'h7 & opcode != 6'h28 & opcode != 6'h29 & opcode != 6'h2b & opcode != 6'h22 & opcode != 6'h26 & opcode != 6'h1)
    begin
      RegWrite = 2'b11;
      RegDst   = 2'b00;
    end

    //LWL
    if (opcode == 6'h22)
    begin
      RegWrite = 2'b01;
      RegDst   = 2'b00;
      MemtoReg = 3'b001;
    end

    //LWR
    if (opcode == 6'h26)
    begin
      RegWrite = 2'b10;
      RegDst   = 2'b00;
      MemtoReg = 3'b001;
    end

    // For memory write operation
    // SB, SH and SW use memory to write (SB SH only write in second cycle)
    if(opcode != 6'h0 & (opcode == 6'h28 | opcode == 6'h29 | opcode == 6'h2b))
    begin
      if (stall==1)
      begin
        MemRead = 1'b1;
      end
      else
      begin
        MemWrite = 1'b1;
      end
    end
    // For memory read operation
    // LW, LB, LBU, LH, LHU, LWL, LWR
    if(opcode != 6'h0 & (opcode == 6'h22 | opcode == 6'h26 | opcode == 6'h23 | opcode == 6'h20 | opcode == 6'h24 | opcode == 6'h21 | opcode == 6'h25))
    begin
      MemRead = 1'b1;
      MemtoReg = 1;
    end

    // J, JAL
    if (opcode==6'h02 | opcode == 6'h03)
    begin
      RegWrite = 2'b0;
      Jump = 1'b1;
      delay_early = 1'b1;
      //JAL
      if (opcode == 6'h03)
      begin
        RegDst = 2'b10;
        MemtoReg = 3'b010;
        RegWrite = 2'b11;
      end
    end

    //Branch Instructions
    if (opcode==6'h4 | opcode==6'h5 | opcode==6'h1 |opcode ==6'h6|opcode ==6'h7)
    begin
      delay_early = 1'b1;
      if (opcode == 6'h1)
      begin
        //BLTZAL or BGEZAL
        if (rt==6'h11 | rt==6'h10)
        begin
          RegDst= 2'b10;
          MemtoReg= 3'b010;
          RegWrite = 2'b11;
        end
      end
    end

  end
endmodule
