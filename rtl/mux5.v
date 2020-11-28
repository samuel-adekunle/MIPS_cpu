module mux5 (
	input logic [20:16] inst20_16,
	input logic [15:11] inst15_11,
	input logic RegDst,
	output logic [4:0] WriteReg
);

	always_comb begin
		case(RegDst) 
			0 : WriteReg <= inst20_16;
			1 : WriteReg <= inst15_11;
		endcase
	end
endmodule