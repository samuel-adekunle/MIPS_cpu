module mux32 (
    input logic [31:0] InputA,
    input logic [31:0] InputB,
    input logic CtlSig,
    output logic [31:0] Output
  );

  always_comb
  begin
    case (CtlSig)
      0:
        Output = InputA;
      1:
        Output = InputB;
    endcase
  end
endmodule
