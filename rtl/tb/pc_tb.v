module pc_tb (
  );
  logic [31:0] PCplus4;
  logic [31:0] instr_address;
  logic clk_enable;
  logic clk;
  logic reset;


  // Generate clock
  initial
  begin
    $dumpfile("pc_waves.vcd");
    $dumpvars(0, pc_tb);
    clk = 0;
    #1
     repeat (1000)
     begin
       #1 clk = !clk;
     end
     $fatal(2, "Fail : test-bench timed out without positive exit.");
  end
  initial
  begin
    reset = 1'b1;
    $display("PCplus4 :%h at instr_address: %h", PCplus4, instr_address);
    @(posedge clk);
    clk_enable <= 1'b1;
    @(posedge clk);
    reset <= 1'b0;
    $display("PCplus4 :%h at instr_address: %h", PCplus4, instr_address);
    repeat (100)
    begin
      @(posedge clk);
      $display("PCplus4 :%h at instr_address: %h", PCplus4, instr_address);
    end
    $display("Finished. Total time = %t", $time);
    $finish;
  end
  PC_1 pc (.PCin(PCplus4), .clk(clk), .reset(reset),
           .clk_enable(clk_enable),.PCout(instr_address));

  add4 adder(.PC(instr_address), .PCplus4(PCplus4));

endmodule

