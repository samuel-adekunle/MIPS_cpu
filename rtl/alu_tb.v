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
	    rs_content = 32'hfffffffc; //-4
	    rt_content = 32'hfffffffb; //-5
	    #5;
	    assert(HI==32'b0);
	    assert(LO== 32'h14); //20
	    functcode = 6'h19; //MULTU
	    rs_content = 32'h0088888a; 
	    rt_content = 32'h0088888b;
	    #5;
	    assert(HI==32'h000048D1);
	    assert(LO==32'h5BFB72EE);
	    functcode = 6'h1a; //DIV
	    rs_content = 32'hfffffff9; //-7
	    rt_content = 32'h00000005; //5
	    #5;
	    assert(HI==32'hfffffffe); //-2
	    assert(LO== 32'hffffffff); //-1
	    functcode = 6'h1b; //DIVU
	    rs_content = 32'h0088888a; 
	    rt_content = 32'h0008888b; 
	    #5;
	    assert(HI==32'h88865);
	    assert(LO== 32'hf); 
	    shamt = 4;
	    functcode = 6'h03; //SRA
	    rt_content = 32'hca000000;
	     #5;
	    assert(ALU_result==32'hfca00000);
	    functcode = 6'h02; //SRL
	    rt_content = 32'h0000004a; 
	     #5;
	    assert(ALU_result == 32'h00000004); 
	    functcode = 6'h2b; //SLTU
	    rs_content = 32'h0088888a; 
	    rt_content = 32'h0088888b; 
	    #5;
	    assert(ALU_result==32'h00000001);
	    functcode = 6'h03; //SLT
	    rs_content = 32'h0000003c; //-4
	    rt_content = 32'h00000014; //20
	    #5; 
	    assert(ALU_result==32'h00000001);
	    opcode = 6'h4; //BEQ
	    rs_content = 32'h0088888a; 
	    rt_content = 32'h0088888a; 
	    #5; 
	    assert(ALU_result == 32'h0);
	    assert(sig_branch == 1'b1); 
	    opcode = 6'h5; //BNE 
	    /*rs_content = 32'h0088888b; 
	    rt_content = 32'h0088888b; 
	    using diff values will give correct response of BNE*/
	    #5; 
	    assert(sig_branch == 1'b0); 
	    opcode = 6'h15; //LUI
	    immediate = 16'h888a;
	    #5; 
	    assert(ALU_result == 32'h888a0000);
	    opcode = 6'h23; //LW
	    rs_content = 32'h0000888a;
	    immediate = 16'h0008; 
	    #5; 
	    assert(ALU_result == 32'h00008892);
        end
    ALU_2 mod (
		.functcode(functcode), .opcode(opcode), .shamt(shamt),
		.immediate(immediate), .rs_content(rs_content), .rt_content(rt_content),
		.sig_branch(sig_branch), .ALU_result(ALU_result), .HI(HI), .LO(LO)
	);
endmodule

 

