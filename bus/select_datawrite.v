module select_datawrite( 
	input logic [31:0] rt_content, 
	input logic [5:0] opcode, 
	output logic [31:0] data_writedata 
); 

always@(rt_content, opcode) begin 
	//SW
	if (opcode==6'h2b) begin
		data_writedata = rt_content; 
	end
	//SB
	if (opcode==6'h28) begin
		data_writedata = {{24{1'b0}}, rt_content[7:0]};
	end
	//SH
	if (opcode==6'h29) begin
		data_writedata = {{16{1'b0}}, rt_content[15:0]};
	end
end
endmodule
