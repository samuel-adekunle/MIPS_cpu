module pc_tb(
);
    timeunit 1ns / 10ps;
    parameter TIMEOUT_CYCLES = 10000;
    logic[31:0] PCin; 
	logic clk;  
	logic reset;  
	logic clk_enable;  
	logic [31:0] PCout;

    integer rst = 32'hBFC00000;
    initial begin
        $dumpfile("pc.vcd");
        $dumpvars(0, pc_tb);
        clk = 0;
        PCin = 10;
        #1
        repeat (10000) begin
            #1 clk = !clk;
        end
        $fatal(2, "Fail : test-bench timed out without positive exit.");
    end
    initial begin
      
        clk_enable = 1;
        // reset = 0;
        // repeat (10) begin

        //     while (clk_enable==1) begin
        //         @(posedge clk);
        //         #1;
        //         assert(PCin+4 == PCout) else $fatal(1, "not incrementing");
        //         $display(PCout);
        //         PCin = PCout;

        //     end

        // end
         reset=1;
        //repeat (5) begin
            $display(PCout);
            if (clk_enable==1) begin
                @(posedge clk);
                #1;
                assert(PCout == rst) else $fatal(1, "not reset");
                $display(PCout);
                PCin = PCout;
                // @(posedge clk);
                // #1;
                // assert(PCin+4 == PCout) else $fatal(1, "not incrementing");
                // $display(PCout);
                // PCin = PCout;

            end

       // end
        reset = 0;
        repeat (10) begin

            while (clk_enable==1) begin
                reset = $urandom_range(0,1);
                @(posedge clk);
                #1;
                if (reset == 1) begin
                    assert(PCout == rst) else $fatal(1, "not reset");
                end
                else begin 
                    assert(PCin+4 == PCout) else $fatal(1, "not incrementing");
                    $display(PCout);
                    PCin = PCout;
                end
                 $display(PCout);
                PCin = PCout;
                
            end
            

        end

    end
    PC_1 p(
        .clk(clk),.clk_enable(clk_enable), .PCin(PCin), .PCout(PCout), .reset(reset)
    ); 
endmodule
