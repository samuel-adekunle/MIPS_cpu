module Registers_tb (
);
	logic clk;  
	logic RegWrite;  
	//5-bit inputs as we have 32 registers in total 
	logic [4:0] ReadReg1;  
	logic [4:0] ReadReg2;  
	logic [4:0] WriteReg;  
	logic reset;
	//WriteData: 32-bit to be written into a register 
	logic [31:0] WriteData;
	//32-bit data read from registers selected by ReadReg, WriteReg 
	logic [31:0] ReadData1;  
	logic [31:0] ReadData2;
	logic [31:0] register_v0; 
	initial begin 
		$dumpfile("reg_tb.vcd");
		$dumpvars(0, Registers_tb);
		clk = 0;
		#1
		repeat (1000) begin
			#1 clk = !clk;
		end
		$fatal(2, "Fail : test-bench timed out without positive exit.");
	end 

	initial begin
        //write to regs
		WriteReg = 0;
		WriteData = $urandom();
		@(posedge clk);
        #1;
		reset = 1;
		
		@(posedge clk);
        #1;
		assert(register_v0==0)else $fatal(1, "did not reset");
		reset = 0;
        repeat (31) begin
			WriteData = $urandom();
			RegWrite = 1;
            @(posedge clk);
            #1;
            $display("writing %h to :%h ",WriteData, WriteReg);
            RegWrite = 0;
			ReadReg1 = WriteReg;
			ReadReg2 = WriteReg; 
			@(posedge clk);
            #1;
            $display("reading %h from :%h ", ReadData1,WriteReg);
			assert(ReadData1==WriteData&&ReadData2==WriteData)else $fatal(1, "fail to write to correct reg");
			$display("current value of v0: %h",register_v0);
			WriteReg = WriteReg+1;
        end
		$display("Finished. Total time = %t", $time);
        $finish;
	end
	Registers r(
	.clk(clk), .RegWrite(RegWrite), .ReadReg1(ReadReg1), .ReadReg2(ReadReg2),
	.WriteReg(WriteReg), .reset(reset), .WriteData(WriteData), .ReadData1(ReadData1),
	.ReadData2(ReadData2), .register_v0(register_v0)
		); 

endmodule 

 
 
