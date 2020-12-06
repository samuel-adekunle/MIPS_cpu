module ALU_2 (
    //inputs
    input logic [5:0] functcode, //instr[5:0]
    input logic [5:0] opcode,
    input logic [4:0] shamt, // instr[10:6]
    input logic [15:0] immediate, //instr[15:0]
    input logic [31:0] rs_content,
    input logic [31: 0] rt_content,

    //output
    output logic sig_branch,
    output logic [31:0] ALU_result,
    output logic [31:0] HI,
    output logic [31:0] LO
  );

  logic[63:0] MultRes;
  integer i; //for loop
  // temp for sra command
  logic signed [31:0] temp, signed_rs, signed_rt;
  logic [31:0] signExtend, zeroExtend;

  always @ (functcode,opcode, rs_content, rt_content, shamt, immediate)
  begin

    // signed value assigment
    signed_rs = rs_content;
    signed_rt = rt_content;

    //FIXME - add default branches in case statements

    // R-type instruction
    if(opcode == 6'h0)
    begin
      case(functcode)
        6'h21 : //ADDU
          ALU_result = rs_content + rt_content;
        6'h23 : //SUBU
          ALU_result = rs_content - rt_content;
        6'h24 : //AND
          ALU_result = rs_content & rt_content;
        6'h25 : //OR
          ALU_result = rs_content | rt_content;
        6'h26 : //XOR
          ALU_result = rs_content ^ rt_content;

        6'h18 : //MULT
        begin
          MultRes = signed_rs*signed_rt;
          HI = MultRes[63:32];
          LO = MultRes[31:0];
        end

        6'h19 : //MULTU
        begin
          MultRes = rs_content*rt_content;
          HI = MultRes[63:32];
          LO = MultRes[31:0];
        end
        6'h1a: //DIV
        begin
          LO = signed_rs/signed_rt;
          HI = signed_rs%signed_rt;
        end
        6'h1b: //DIVU
        begin
          LO = rs_content/rt_content;
          HI = rs_content%rt_content;
        end

        6'h03 : //SRA
        begin
          temp = rt_content;
          for(i = 0; i < shamt; i = i + 1)
          begin
            temp = {temp[31],temp[31:1]};
            //add the lsb for msb
          end
          ALU_result = temp;
        end
        6'h07 : //SRAV
        begin
          temp = rt_content;
          for(i = 0; i < rs_content; i = i + 1)
          begin
            temp = {temp[31],temp[31:1]};
            //add the lsb for msb
          end
          ALU_result = temp;
        end
        6'h02 : //SRL
          ALU_result = (rt_content >> shamt);
        6'h06 : //SRLV
          ALU_result = (rt_content >> rs_content);

        6'h00 : //SLL
          ALU_result = (rt_content << shamt);
        6'h04 : //SLLV
          ALU_result = (rt_content << rs_content);

        6'h2b : //SLTU
        begin
          if(rs_content < rt_content)
          begin
            ALU_result = 1;
          end
          else
          begin
            ALU_result = 0;
          end
        end

        6'h2a : //SLT
        begin
          if(signed_rs < signed_rt)
          begin
            ALU_result = 1;
          end
          else
          begin
            ALU_result = 0;
          end
        end
      endcase //case
    end // if



    // I type
    else
    begin

      signExtend = {{16{immediate[15]}}, immediate};
      zeroExtend = {{16{1'b0}}, immediate};

      case(opcode)
        6'h9 : //ADDIU
          ALU_result = rs_content + signExtend;

        6'h0c : // ANDI
          ALU_result = rs_content & zeroExtend;

        6'h0e: // XORI
          ALU_result = rs_content ^ zeroExtend;

        6'h4 : // BEQ
        begin
          // if the result is zero, they are equal go branch!
          ALU_result = signed_rs - signed_rt;
          if(ALU_result == 0)
          begin
            sig_branch = 1'b1;
          end
          else
          begin
            sig_branch = 1'b0;
          end
        end

        6'h5 : // BNE
        begin
          // if the result is not zero, they are not equal go branch!
          ALU_result = signed_rs - signed_rt;
          if(ALU_result != 0)
          begin
            sig_branch = 1'b1;
            ALU_result = 1'b0;
          end
          else
          begin
            sig_branch = 1'b0;
          end
        end

        6'b010101 : // LUI
          ALU_result = {immediate, {16{1'b0}}};

        6'b010011 : // ORI
          ALU_result = rs_content | zeroExtend;

        6'b001010 : // SLTI
        begin
          if(signed_rs < $signed(signExtend))
          begin
            ALU_result = 1;
          end
          else
          begin
            ALU_result = 0;
          end
        end

        6'b001011 : // SLTIU
        begin
          if(rs_content < signExtend)
          begin
            ALU_result = 1;
          end
          else
          begin
            ALU_result = 0;
          end
        end
        6'h28 : // SB
          ALU_result = signed_rs + signExtend;
        6'h29 : // SH
          ALU_result = signed_rs + signExtend;
        6'h2b : // SW
          ALU_result = signed_rs + signExtend;
        6'h23 : // LW
          ALU_result = signed_rs + signExtend;
        6'h24 : // LBU
          ALU_result = signed_rs + signExtend;
        6'h25 : // LHU
          ALU_result = signed_rs + signExtend;
        //left with LH, LWL, LWR, some branch instrs?
      endcase
    end
  end


  initial
  begin
    $monitor("opcode: %6b, Rs content: %32b, rt content: %32b, signExtendImm = %32b, result: %32b\n",
             opcode, rs_content, rt_content, signExtend, ALU_result);
  end

endmodule
