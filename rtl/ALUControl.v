module ALUControl (	
	
	input logic [2:0] ALUOp,
	input logic [5:0] FunctCode,
	output logic [4:0] ALUCtl
);


    always_comb begin
        if (ALUOp == 3'b000)
        begin
            ALUCtl=2; //addition (LW, SW, ADDU, ADDIU)   
        end
        
        else if (ALUOp == 3'b001)
        begin 
            ALUCtl=6; //subtraction (BEQ, BNE, branch instructions?) 
        end
        else if(ALUOp==3'b100) //AND (ANDI) 
        begin
            ALUCtl=0;
        end
        else if(ALUOp==3'b101) //OR (ORI)
        begin
            ALUCtl=1;
        end
	else if(ALUOp==3'b111) //XOR (XORI)
        begin
            ALUCtl=5;
        end
	else if(ALUOp==3'b110) //SLT Signed (SLTI)
        begin
            ALUCtl=7;
        end
	else if(ALUOp==3'b101) //SLT Unsigned (SLTIU)
        begin
            ALUCtl=8;
        end
        else
            begin
                case (FunctCode)
                    6'b100001: ALUCtl=2;        //addition (ADDU) 
                    6'b100011: ALUCtl=6;        //subtraction (SUBU) 
		    6'b011010: ALUCtl=3;        //division (DIV)
		    6'b011011: ALUCtl=4;        //division unsigned (DIVU)
		    6'b011000: ALUCtl=11;       //multiplication (MULT) 
		    6'b011001: ALUCtl=12;       //multiplication unsigned (MULTU)
                    6'b100100: ALUCtl=0;        //AND (AND)
                    6'b100101: ALUCtl=1;        //OR (OR) 
   		    6'b100110: ALUCtl=5;        //XOR (XOR)
                    6'b101010: ALUCtl=7;        //SLT signed (SLT) 
                    6'b101011: ALUCtl=8;        //SLT unsigned (SLTU) 
                    6'b000000: ALUCtl=9;        //Shift left logical (SLL) 
                    6'b000010: ALUCtl=10;       //Shift right logical (SRL)
		    6'b000100: ALUCtl = 13 //Shift Left Logical Variable (SLLV) 
		    6'b000110: ALUCtl = 14 //Shift right logical variable (SRLV) 
		    6'b000011: ALUCtl = 15 //Shift right arithmetic (SRA) 
		    6'b000111: ALUCtl = 16 //shift right arithmetic variable (SRAV) 
                    default: ALUCtl=31; // should not happen   
                endcase 
        end
end

endmodule
