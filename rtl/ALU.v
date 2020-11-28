module ALU (  
    input logic [3:0] ALUControl,
    input logic [4:0] shiftvalue,
    input logic [31:0] Data1,
    input logic [31:0] Data2,
    output logic zero,
    output logic [31:0] ALUresult,
    output logic [31:0] HI,
    output logic [31:0] LO
	
);

    logic[63:0] MultRes;

    always @(ALUControl, Data1, Data2)
    begin 
        case (ALUControl)
            0: ALUresult <= Data1 & Data2;            //and
            1: ALUresult <= Data1 | Data2;            //or
	    5: ALUresult <= Data1^Data2; 	      //xor
    
            2: ALUresult <= Data1 + Data2;            //add
            6: ALUresult <= Data1 - Data2;            //subtract

	    3: begin //division
		LO <= $signed(Data1)/$signed(Data2); //LO contains quotient
		HI <= $signed(Data1)%$signed(Data2); //HI contains remainder 
	    end
	    4: begin //division unsigned
		LO <= Data1/Data2; 
		HI <= Data1%Data2; 
	    end

	    11: begin
		MultRes <= $signed(Data1)*$signed(Data2); //multiplication
		LO <= MultRes[63:32];
		HI <= MultRes[31:0];
	    end
	    12: begin 
		MultRes <= Data1*Data2	//multiplication unsigned
		LO <= MultRes[63:32];
		HI <= MultRes[31:0];
    	    end
            7: ALUresult <= $signed(Data1) < $signed(Data2) ? 1 : 0;    //slt signed
            8: ALUresult <= Data1 < Data2 ? 1 : 0; //slt unsigned
            9: ALUresult <= Data2 <<shiftvalue;  //sll    
            10: ALUresult <= Data2 >>shiftvalue; //srl
            default: ALUresult <= 0;   
        endcase    
		zero = (Data2 - Data1 == 0);
    end 
    
endmodule
