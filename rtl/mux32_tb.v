module mux32_tb(
);
    logic [31:0] InputA;
    logic [31:0] InputB;
    logic CtlSig;
    logic [31:0] Output;
    
    initial begin
        $dumpfile("mux32_waves.vcd");
        $dumpvars(0, mux32_tb);
    end

    initial begin
        InputA = 32'h00000000;
        InputB = 32'h00000000;
        CtlSig = 0;
        repeat (50) begin
            #1;
            $display("In: %b, %b select %b. Out %b.", InputA, InputB, CtlSig, Output);
            InputA = $random;
            InputB = $random;

            #1;
            assert(WriteReg == InputA);

            RegDst <= 1;
            #1;
            $display("In: %b, %b select %b. Out %b.", InputA, InputB, CtlSig, Output);
            assert(WriteReg == InputB);
        
            #1;
            RegDst <= 0;
        end
        $display("Finished. Total time = %t", $time);
        $finish;
    end
    mux32 mod(
        .InputA(InputA), .InputB(InputB), .CtlSig(CtlSig), .Output(Output)
    ); 
endmodule

