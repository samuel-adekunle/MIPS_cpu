module add4 (
    input logic[31:0] PC,
    output logic[31:0] PCplus4,
    input logic clk_en
  );
  always_comb
  begin
    PCplus4 = PC + 4;
  end
endmodule
