module Add_ALU(
	input logic [31:0] PCplus4,
	input logic [31:0] extendImm,
	output logic [31:0] Add_ALUresult
);

	always_comb begin
		Add_ALUresult = PCplus4 + extendImm;
	end
endmodule

