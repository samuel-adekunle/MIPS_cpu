module control_unit (
    output logic JR,
    output logic Jump,
    output logic [1:0] RegWrite,
    output logic MemRead,
    output logic MemWrite,
    output logic [1:0] RegDst, // if this is 0 select rt, 1 select rd, 2 select $ra 
    output logic [1:0] MemtoReg, //if this is 2 select PCplus4
    output logic [1:0] HI_write,
    output logic [1:0] LO_write,
    input logic [5:0] opcode,
    input logic [5:0] funct,
    input logic [5:0] rt
  );

  always @(opcode, funct, rt)
  begin

    // First, reset all signals
    JR = 1'b0;
    Jump = 1'b0;
    MemRead  = 1'b0;
    MemWrite = 1'b0;
    RegWrite = 2'b0;
    RegDst   = 2'b0;
    MemtoReg = 2'b0;

    // R type
    if(opcode == 6'h0)
    begin
      RegDst = 1;
      //if JR
      if (funct == 6'h08)
      begin
        JR = 1'b1;
      end

      else
      begin
        RegWrite = 2'b11;
      end
      //if JALR
      if (funct == 6'h09)
      begin
        JR = 1'b1;
	MemtoReg = 2;
      end
      //if MTHI 
      if (funct == 6'h11)
      begin
	HI_write = 2'b11; 
      end
      //if MTLO
      if (funct == 6'h13)
      begin
	LO_write = 2'b11;
      end 
    end
    // If R-type, don't enter this block
    // For R-type, BEQ, BNE, BEGZ, BLTZ, BGTZ, BLEZ, SB, SH and SW there is no need to register write
    // For LWL and LWR, we regwrite 01 and 10 instead
    if(opcode != 6'h0 & opcode != 6'h4 & opcode != 6'h5 & opcode != 6'h6 & opcode != 6'h7 & opcode != 6'h28 & opcode != 6'h29 & opcode != 6'h2b & opcode != 6'h22 & opcode != 6'h26 & (opcode != 6'h1 | rt != 6'h0) & (opcode != 6'h1 | rt != 6'h1))
    begin
      RegWrite = 2'b11;
      RegDst   = 2'b00;
    end

    //LWL 
    if (opcode == 6'h22)
    begin
      RegWrite = 2'b01;
      RegDst   = 2'b00;
    end

    //LWR
    if (opcode == 6'h26)
    begin
      RegWrite = 2'b10;
      RegDst   = 2'b00;
    end

    // For memory write operation
    // SB, SH and SW use memory to write
    if(opcode != 6'h0 & (opcode == 6'h28 | opcode == 6'h29 | opcode == 6'h2b))
    begin
      MemWrite = 1'b1;
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
      Jump = 1'b1;
      //JAL
      if (opcode == 6'h03) begin
	RegDst = 2'b10;
        MemtoReg = 2'b10;
	RegWrite = 2'b11; 
      end
    end 
  end
endmodule
