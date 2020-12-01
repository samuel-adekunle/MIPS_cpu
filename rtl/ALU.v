module ALU (  
    input logic [4:0] ALUControl,
    input logic [4:0] shiftvalue, //instr[10:6]
    input logic [31:0] Data1,
    input logic [31:0] Data2,
    output logic zero,
    output logic [31:0] ALUresult,
    output logic [31:0] HI,
    output logic [31:0] LO
	
);

    logic[63:0] MultRes;
    integer i; //for loop 
    // temp for sra command 
    logic signed [31:0] temp, signed_rs, signed_rt;  

    always@(ALUControl, shiftvalue, Data1, Data2)
    begin 
        case (ALUControl)
            0: ALUresult = Data1 & Data2;            //and
            1: ALUresult = Data1 | Data2;            //or
	    5: ALUresult = Data1^Data2; 	      //xor
    
            2: ALUresult = Data1 + Data2;            //add
            6: ALUresult = Data1 - Data2;            //subtract

	    3: begin //division
		LO = $signed(Data1)/$signed(Data2); //LO contains quotient
		HI = $signed(Data1)%$signed(Data2); //HI contains remainder 
	    end
	    4: begin //division unsigned
		LO = Data1/Data2; 
		HI = Data1%Data2; 
	    end

	    11: begin
		MultRes = $signed(Data1)*$signed(Data2); //multiplication
		LO = MultRes[63:32];
		HI = MultRes[31:0];
	    end
	    12: begin 
		MultRes = Data1*Data2;	//multiplication unsigned
		LO = MultRes[63:32];
		HI = MultRes[31:0];
    	    end
            7: ALUresult = $signed(Data1) < $signed(Data2) ? 1 : 0;    //slt signed
            8: ALUresult = Data1 < Data2 ? 1 : 0; //slt unsigned
            9: ALUresult = Data2 <<shiftvalue;  //sll    
            10: ALUresult = Data2 >>shiftvalue; //srl
	    13: ALUresult = Data2 << Data1; //sllv
	    14: ALUresult = Data2 >> Data1; //srlv
	    15: begin  			//sra
                     temp = Data2; 
                     for(i = 0; i < shiftvalue; i = i + 1) begin 
			temp = {temp[31],temp[31:1]}; //add the lsb for msb 
                      end 
		     ALUresult = temp; 
		end 	
	    16: begin //srav
		     temp = Data2;
		     for (i=0; i < Data1; i = i+1) begin
			temp = temp = {temp[31],temp[31:1]}; //add the lsb for msb 
		     end
		     ALUresult = temp;
		end
            default: ALUresult = 0;   
        endcase    
		zero = (Data2 - Data1 == 0);
    end 
    
endmodule
