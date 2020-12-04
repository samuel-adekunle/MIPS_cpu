module control_unit(
	output logic JR,
				  Jump,
				  RegWrite,
				  MemRead,
				  MemWrite,
				  RegDst, // if this is 0 select rt, otherwise select rd
				  MemtoReg,
				  write_hi,
				  write_lo,
				  read_hi_lo,
	input logic [5:0] opcode, funct
);
	
	always @(opcode, funct) begin
	
		// First, reset all signals
		JR = 1'b0;
		Jump = 1'b0;
		MemRead  = 1'b0;
		MemWrite = 1'b0;
		RegWrite = 1'b0;
		RegDst   = 1'b0;
		MemtoReg = 1'b0;
		write_hi = 1'b0;
		write_lo = 1'b0;
		read_hi_lo= 1'b0;
		
		// R type
		if(opcode == 6'h0) begin
			RegDst = 1'b1;
			//if JR
			if (funct == 6'h08) begin
				JR = 1'b1;

			end
			//MTHI or DIV/MULT
			else if (funct == 6'h11||funct ==6'h18||funct ==6'h19||funct ==6'h1a||funct ==6'h1b) begin
				write_hi = 1'b1;
			end
			//MTLO or DIV/MULT
			else if (funct == 6'h13||funct ==6'h18||funct ==6'h19||funct ==6'h1a||funct ==6'h1b) begin
				write_lo = 1'b1;
			end
			//MFHI, MFLO turn write data of reg file to hi/lo
			else if (funct == 6'h10||funct ==6'h12)begin
				read_hi_lo= 1'b1;
			end
			//if JALR
			else if (funct == 6'h09) begin
				Jump = 1'b1;
			end
			else begin
				RegWrite = 1'b1;
			end
		end
		// If R-type, don't enter this block
		// For R-type, BEQ, BNE, SB, SH and SW there is no need to register write
		if(opcode != 6'h0 & opcode != 6'h4 & opcode != 6'h5 & opcode != 6'h28 & opcode != 6'h29 & opcode != 6'h2b) begin
			RegWrite = 1'b1;
			RegDst   = 1'b0;
		end
		// For memory write operation
		// SB, SH and SW use memory to write
		if(opcode != 6'h0 & (opcode == 6'h28 | opcode == 6'h29 | opcode == 6'h2b)) 			begin
			MemWrite = 1'b1;
		end
		// For memory read operation
		// LW
		if(opcode != 6'h0 & (opcode == 6'h23))begin
			MemRead = 1'b1;
			MemtoReg = 1'b1; 
		end
		// J type (J, JAL) 
		if (opcode==6'h02 | opcode == 6'h03) begin
			Jump = 1'b1;
		end
	end
	
	
	
endmodule
