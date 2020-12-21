module mux5_tb(
  );
  logic [20:16] inst20_16;
  logic [15:11] inst15_11;
  logic [1:0] RegDst;
  logic [4:0] WriteReg;

  initial
  begin
    $dumpfile("mux5_waves.vcd");
    $dumpvars(0, mux5_tb);
  end

  initial
  begin
    inst20_16 = 5'b00000;
    inst15_11 = 5'b00000;
    RegDst = 0;
    repeat (50)
    begin
      #1;
      $display("In: %b, %b select %b. Out %b.", inst20_16, inst15_11, RegDst, WriteReg);
      inst20_16 = $random;
      inst15_11 = $random;

      #1;
      assert(WriteReg == inst20_16);
      RegDst <= 1;

      #1;
      $display("In: %b, %b select %b. Out %b.", inst20_16, inst15_11, RegDst, WriteReg);
      assert(WriteReg == inst15_11);
      RegDst <= 2;

      #1;
      $display("In: %b, %b select %b. Out %b.", inst20_16, inst15_11, RegDst, WriteReg);
      assert(WriteReg == 31);
      RegDst <= 0;
    end
    $display("Finished. Total time = %t", $time);
    $finish;
  end
  mux5 mod(
         .inst20_16(inst20_16), .inst15_11(inst15_11), .RegDst(RegDst), .WriteReg(WriteReg)
       );
endmodule

