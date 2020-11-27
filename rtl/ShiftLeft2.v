module ShiftLeft2( 
	input logic [31:0] ShiftIn, 
	output logic [31:0] ShiftOut 
); 

assign ShiftOut = ShiftIn << 2;    

endmodule 
