//`include "rtl/Add_ALU.v"

module addalu_tb(
  );
  logic [31:0] PCplus4;
  logic [31:0] extendImm;
  logic [31:0] Add_ALUresult;

  initial
  begin
    $dumpfile("addalu_waves.vcd");
    $dumpvars(0, addalu_tb);
  end
  initial
  begin
    PCplus4 = 32'hBFC00000;
    extendImm = 32'h00000000;
    repeat (100)
    begin
      #1;
      $display("result :%h at PC_next: %h and Imm: %h", Add_ALUresult, PCplus4, extendImm);
      extendImm=$random();
      #1;
      assert(Add_ALUresult == extendImm + PCplus4);
    end
    $display("Finished. Total time = %t", $time);
    $finish;
  end
  Add_ALU mod(
            .PCplus4(PCplus4), .extendImm(extendImm), .Add_ALUresult(Add_ALUresult)
          );
endmodule

