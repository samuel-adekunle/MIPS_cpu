module mux32_3 (
    input logic [31:0] InputA,
    input logic [31:0] InputB,
    input logic [31:0] InputC,
    input logic [1:0] CtlSig,
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
    endcase
  end
endmodule
