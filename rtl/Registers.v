module Registers (
    input logic clk,
    input logic RegWrite,
    input logic reset,
    //5-bit inputs as we have 32 registers in total
    input logic [4:0] ReadReg1,
    input logic [4:0] ReadReg2,
    input logic [4:0] WriteReg,
    //WriteData: 32-bit input to be written into a register
    input logic [31:0] WriteData,
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

  //at rising edge of clk, if RegWrite_en is 1, write WriteData into register selected by WriteReg

  always_ff @(posedge clk)
  begin
    if (reset)
    begin
      for (i = 0; i < 31; i = i + 1)
      begin
        register[i] <= 32'b0;
      end
    end
    if (RegWrite&&!reset)
    begin
      register[WriteReg] <= WriteData;
    end
  end

endmodule
