`include "rtl/SignExtend.v"

module signextend_tb();
  logic [15:0] instr15_0;
  logic [31:0] Extend32;

  initial
  begin
    $dumpfile("signextend_waves.vcd");
    $dumpvars(0, signextend_tb);
  end

  initial
  begin
    instr15_0 = 16'h0000;
    repeat (70)
    begin
      #1;
      $display("signextend :%h instr15_0: %h", Extend32, instr15_0);
      instr15_0=$urandom();
    end
    $display("Finished. Total time = %t", $time);
    $finish;
  end

  SignExtend mod(
               .instr15_0(instr15_0),
               .Extend32(Extend32)
             );
endmodule
