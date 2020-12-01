module control_unit(
	output logic RegDst,
	output logic Jump,
	output logic Branch,
	output logic MemRead,
	output logic MemtoReg,
	output logic [2:0] ALUOp,
	output logic MemWrite,
	output logic ALUSrc, 
	output logic RegWrite,
	input logic [5:0] opcode, funct
);
	
	// always @(opcode, funct) begin
	// 	// First, reset all signals
	// 	MemRead = 1'b0;
	// 	RegDst = 1'b0;
	// 	Jump = 1'b0;
	// 	Branch = 1'b0;
	// 	MemRead = 1'b0;
	// 	MemtoReg = 1'b0;
	// 	ALUOp = 3'b000;
	// 	MemWrite = 1'b0;
	// 	ALUSrc = 1'b0;
	// 	RegWrite = 1'b0;
		
	// 	// R type
	// 	if(opcode == 6'h0) begin
	// 		RegDst = 1'b1; 
	// 		ALUSrc = 1'b1;
	// 		// if not JR
	// 		if(funct != 6'h08) begin
	// 			RegWrite = 1'b1;
	// 		end
	// 	end
	// 	// For LUI there is no need to register read
	// 	if(opcode != 6'b010101) begin
	// 		ALUSrc = 1'b1;
	// 	end
	// 	// If r-type, don't enter this block
	// 	// For r-type, beq, bne, sb, sh and sw there is no need to register write
	// 	if(opcode != 6'h0 & opcode != 6'h4 & opcode != 6'h5 & opcode != 6'h28 & opcode != 6'h29 & opcode != 6'h2b) begin
	// 		RegWrite = 1'b1;
	// 		RegDst   = 1'b0;
	// 	end
	// 	// For branch instructions
	// 	if(opcode == 6'h4 | opcode == 6'h5) begin
	// 		Branch   = 1'b1;
	// 	end
	// 	// For memory write operation
	// 	// sb, sh and sw use memory to write
	// 	if(opcode != 6'h0 & (opcode == 6'h28 | opcode == 6'h29 | opcode == 6'h2b)) begin
	// 		MemWrite = 1'b1;
	// 		ALUSrc  = 1'b1;
	// 	end
	// 	// For memory read operation
	// 	// lw, 
	// 	if(opcode != 6'h0 & (opcode == 6'h23))begin
	// 		MemRead = 1'b1;
	// 	end
	// 	// J type
	// 	if (opcode == 000010) 
	// 	// All signals already 0.
	// end
	
	
	
endmodule
