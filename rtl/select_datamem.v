module select_datamem( 
	input logic [31:0] fullread, 
	input logic [5:0] opcode, 
	input logic [1:0] data_address2LSB, 
	output logic [31:0] ReadData 
); 

always@(fullread,opcode, data_address2LSB) begin 
	//LW
	if (opcode==6'h23) begin
		ReadData = fullread; 
	end
	//LB
	if (opcode==6'h20) begin
		case(data_address2LSB[1:0])
		3: ReadData = {{24{fullread[31]}}, fullread[31:24]};
		2: ReadData = {{24{fullread[23]}}, fullread[23:16]};
		1: ReadData = {{24{fullread[15]}}, fullread[15:8]};
		0: ReadData = {{24{fullread[7]}}, fullread[7:0]};
		endcase
	end
	//LBU 
	if (opcode==6'h24) begin
		case(data_address2LSB[1:0])
		3: ReadData = {{24{1'b0}}, fullread[31:24]};
		2: ReadData = {{24{1'b0}}, fullread[23:16]};
		1: ReadData = {{24{1'b0}}, fullread[15:8]};
		0: ReadData = {{24{1'b0}}, fullread[7:0]};
		endcase
	end
	//LH
	if (opcode==6'h21) begin
		case(data_address2LSB[0])
		1: ReadData = {{16{fullread[31]}}, fullread[31:16]};
		0: ReadData = {{16{fullread[15]}}, fullread[15:0]};
		endcase
	end
	//LHU
	if (opcode==6'h25) begin
		case(data_address2LSB[0])
		1: ReadData = {{16{1'b0}}, fullread[31:16]};
		0: ReadData = {{16{1'b0}}, fullread[15:0]};
		endcase
	end
end
endmodule
