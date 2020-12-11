module single_reg(
    input logic clk,
    input logic [1:0] RegWrite, //write_en
    input logic reset,
    //WriteData: 32-bit input to be written into a register
    input logic [31:0] WriteData,
    //32-bit data read from registers selected by ReadReg, WriteReg
    output logic [31:0] ReadData
  );

  logic [31:0] register;

  //output. 32-bit data read from registers selected by ReadReg, WriteReg
  assign ReadData = register;
  //at rising edge of clk, if RegWrite_en is 11, write WriteData into register selected by WriteReg
  always_ff @(posedge clk)
  begin
    if (reset)
    begin
      register <=32'h0;
    end
    else if (RegWrite == 2'b11 && !reset)
    begin
      register <= WriteData;
    end
  end

endmodule
