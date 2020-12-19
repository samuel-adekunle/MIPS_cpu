module mux32_6 (
    input logic [31:0] InputA,
    input logic [31:0] InputB,
    input logic [31:0] InputC,
    input logic [31:0] InputD,
    input logic [31:0] HI_reg,
    input logic [31:0] LO_reg,
    input logic [2:0] CtlSig,
    output logic [31:0] Output
  );

  always_comb
  begin
    case (CtlSig)
      0:
        Output = InputA;
      1:
        Output = InputB;
      2:
        Output = InputC;
      3:
        Output = HI_reg;
      4:
        Output = LO_reg;
      5:
        Output = InputD;
    endcase
  end
endmodule
