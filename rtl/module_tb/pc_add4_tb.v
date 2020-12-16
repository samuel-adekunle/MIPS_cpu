module pc_add4_tb;
  timeunit 1ns / 10ps;
  parameter TIMEOUT_CYCLES = 10000;
  logic[31:0] PCin;
  logic clk;
  logic reset;
  logic clk_enable;
  logic [31:0] PCout;

  integer rst = 32'hBFC00000;
  initial
  begin
    $dumpfile("pc.vcd");
    $dumpvars(0, pc_add4_tb);
    clk = 0;
    PCin = rst;
    #1
     repeat (10000)
     begin
       #1 clk = !clk;
     end
     $fatal(2, "Fail : test-bench timed out without positive exit.");
  end
  initial
  begin
    clk_enable = 1;
    reset=1;
    repeat (5) //high rst
    begin
      if (clk_enable==1)
      begin
        @(posedge clk);
        #1;
        assert(PCout == rst) else
                $fatal(1, "not reset");
        $display("%h",PCout);
        PCin = PCout;
        @(posedge clk);
        #1;
        assert(PCin == PCout) else
                $fatal(1, "incrementing");
        $display("%h",PCout);
        PCin = PCout;
      end
    end
    reset = 0; //random reset
    repeat (10)
    begin
      reset = $urandom_range(0,1);
      @(posedge clk);
      #1;
      if (reset == 1)
      begin
        assert(PCout == rst) else
                $fatal(1, "not reset");
      end
      else
      begin
        assert(PCin+4 == PCout) else
                $fatal(1, "not incrementing");
        PCin = PCout;
      end
      $display("random reset: %h",PCout);
      PCin = PCout;
    end

    clk_enable = 0;
    PCin = 1;
    repeat (5)
    begin
      @(posedge clk);
      #1;
      begin
          $display("%h",PCout);
        // assert(PCout == 1) else
        //         $fatal(1, "incrementing");
      end
    end
    clk_enable = 1;
    PCin = rst;
    reset = 1;
     @(posedge clk);
      #1;
    assert(PCout == rst);
    reset =0;
    repeat (5)
    begin
      @(posedge clk);
      #1
      $display("pcin %h pcout %h", PCin, PCout);
    //   assert(PCin+4 == PCout) else
    //           $display("pcin %h pcout %h", PCin, PCout);
        PCin<=PCout;
    end

  $finish;
end

logic[31:0] PCplus4;
add4 a(
       .PC(PCout),
       .PCplus4(PCplus4)
     );
PC_1 p(
       .clk(clk),
       .clk_enable(clk_enable),
       .PCin(PCplus4),
       .PCout(PCout),
       .reset(reset)
     );
endmodule
