
module instr_mem_tb(
);
    logic [31:0] address;
    logic clk;
    logic [31:0] instr; 

    
    initial begin
        $dumpfile("instr_mem_Read.vcd");
        $dumpvars(0, instr_mem_tb);
        clk = 0;
        #1
        repeat (1000) begin
            #1 clk = !clk;
        end
        $fatal(2, "Fail : test-bench timed out without positive exit.");
    end
    initial begin
        address = 32'hBFC00000;
        repeat (10) begin
            @(posedge clk);
            #1;
            $display("instruction :%h at address %h", instr, address);
            address=address+4;
        end
        address = 32'h0;
        repeat (21) begin
            @(posedge clk);
            #1;
            $display("data/instruction :%h at address %h", instr, address);
            address=address+4;
        end
        address = 32'hbfbc0004;//branch back
        repeat (10) begin
            @(posedge clk);
            #1;
            $display("branch back instruction :%h at address %h", instr, address);
            address=address+4;
        end
        address = 32'hbfc3fffc; //branch forwards
        repeat (10) begin
            @(posedge clk);
            #1;
            $display("branch forwards instruction :%h at address %h", instr, address);
            address=address+4;
        end
        address = 32'hc0000000; //jump forwards
        repeat (10) begin
            @(posedge clk);
            #1;
            $display("jump forwards instruction :%h at address %h", instr, address);
            address=address+4;
        end
        address = 32'hbfc01000;
        @(posedge clk);
         $display("misc instruction :%h at address %h", instr, address);
        $display("Finished. Total time = %t", $time);
        $finish;
    end
    instr_mem m(
        .address(address), .clk(clk), .instr(instr)
    ); 
endmodule
      
      