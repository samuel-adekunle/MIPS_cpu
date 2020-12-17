module PC_1 (
    input logic[31:0] PCin,
    input logic clk,
    input logic reset,
    input clk_enable,
    input logic stall, //for sb, sh
    input logic [31:0] prev_instr,
    output logic [31:0] PCout
  );


  always_ff @(posedge clk)
  begin
    if (reset)
    begin
      PCout <= 32'hBFC00000;
    end
    if (stall)
    begin
      PCout <= prev_instr;
    end
    else if (clk_enable)
    begin
      PCout <= PCin;
    end

  end


endmodule
