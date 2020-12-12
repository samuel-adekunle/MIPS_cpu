module Registers (
    input logic clk,
    input logic [1:0] RegWrite,
    input logic reset,
    //5-bit inputs as we have 32 registers in total
    input logic [4:0] ReadReg1,
    input logic [4:0] ReadReg2,
    input logic [4:0] WriteReg,
    //WriteData: 32-bit input to be written into a register
    input logic [31:0] WriteData,
    //2 LSB of data_address for LWL and LWR implementation
    input logic [1:0] data_address2LSB, 
    //32-bit data read from registers selected by ReadReg, WriteReg
    output logic [31:0] ReadData1,
    output logic [31:0] ReadData2,
    output logic [31:0] register_v0
  );

  //32 32-bit registers. Initialise register values using regmem.txt
  //REVIEW logic [31:0] register [32];
  logic [31:0] register [0:31];
  //for loop
  integer i;

  // initial
  // begin
  //   $readmemh("data/regmem.txt", register, 0, 31);
  // end

  //output ports. 32-bit data read from registers selected by ReadReg, WriteReg
  assign ReadData1 = register[ReadReg1];
  assign ReadData2 = register[ReadReg2];
  assign register_v0 = register[2];

  //at rising edge of clk, if RegWrite_en is 11, write WriteData into register selected by WriteReg

  always_ff @(posedge clk)
  begin
    if (reset)
    begin
      for (i = 0; i < 31; i = i + 1)
      begin
        register[i] <= 32'b0;
      end
    end
    if (RegWrite == 2'b11 && !reset)
    begin
      register[WriteReg] <= WriteData;
    end
	
    // LWL to replace WriteData
    if (RegWrite == 2'b01 && !reset)
    begin
	case (data_address2LSB) 
	0: register[WriteReg] <= {WriteData[7:0], ReadData2[23:0]};
	1: register[WriteReg] <= {WriteData[15:0], ReadData2[15:0]}; 
	2: register[WriteReg] <= {WriteData[23:0], ReadData2[7:0]}; 
	3: register[WriteReg] <= {WriteData[31:0]}; 
	endcase 
    end

    //LWR to replace WriteData 
    if (RegWrite == 2'b10 && !reset)
    begin
	case (data_address2LSB) 
	0: register[WriteReg] <= {WriteData[31:0]}; 
	1: register[WriteReg] <= {ReadData2[31:24], WriteData[23:0]}; 
	2: register[WriteReg] <= {ReadData2[31:16], WriteData[15:0]}; 
	3: register[WriteReg] <= {ReadData2[31:8], WriteData[7:0]}; 
	endcase 
    end

  end

endmodule
