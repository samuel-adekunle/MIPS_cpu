module alu_tb(
);
    	logic [5:0] functcode; //instr[5:0]
	logic [5:0] opcode;
	logic [4:0] shamt; // instr[10:6] 
	logic [15:0] immediate; //instr[15:0] 
	logic [31:0] rs_content, rt_content;
	
	logic sig_branch;
	logic [31:0] ALU_result;
	logic [31:0] HI;
	logic [31:0] LO;

    
    initial begin
        $dumpfile("alu_waves.vcd");
        $dumpvars(0, alu_tb);
    end
    initial begin
	//set all to 0 
        rs_content = 32'h0;
	rt_content = 32'h0;
	opcode = 6'h0; 
	functcode = 6'h0;
	shamt = 5'h0;
	immediate = 16'h0;
            #1;
            $monitor("functcode:%h opcode:%h shamt:%h immediate:%h rs_content:%h rt_content:%h sig_branch:%b ALU_result:%h HI:%h LO:%h", 
	functcode, opcode, shamt, immediate, rs_content, rt_content,
	sig_branch, ALU_result, HI, LO);
            #5;
	    functcode = 6'h18; //MULT
	    rs_content = 32'b111100; //-4
	    rt_content = 32'b111011; //-5
	    #5;
	    assert(HI==32'h);
	    assert(LO== 32'h); 
	    functcode = 6'h19; //MULTU
	    rt_content = 32'hffff8abc;
	    #5;
	    assert(HI==
	    functcode = 6'h1a; //DIV
	    rs_content = 
	    rt_content = 
	    #5;
	    functcode = 6'h1b; //DIVU
	    rs_content = 
	    rt_content = 
	    #5;
	    functcode = 6'h03; //SRA
	    rs_content = 
	    rt_content = 
	    shamt = 
	     #5;
	    functcode = 6'h02; //SRL
	    rs_content = 
	    rt_content = 
	    shamt = 
	     #5;
	    functcode = 6'h2b; //SLTU
	    rs_content = 
	    rt_content = 
	    #5;
	    functcode = 6'h03; //SLT
	    rs_content = 
	    rt_content = 
	    #5; 
	    opcode = 6'h4; //BEQ
	    rs_content = 
	    rt_content = 
	    #5; 
	    opcode = 6'h5; //BNE
	    #5; 
	    opcode = 6'h15; //LUI
	    rs_content = 
	    rt_content = 
	    #5; 
	    opcode = 6'h23; //LW
	    rs_content = 
	    rt_content = 
	    #5; 
	    assert(
        end
        $display("Finished. Total time = %t", $time);
        $finish;
    end
    ALU_2 alu (
		.functcode(functcode), .opcode(opcode), .shamt(shamt),
		.immediate(immediate), .rs_content(rs_content), .rt_content(rt_content),
		.sig_branch(Branch), .ALU_result(data_address), .HI(HI), .LO(LO)
	);
endmodule

 

