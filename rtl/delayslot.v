module delayslot ( 
    input logic clk, 
    input logic [1:0] Branch, 
    input logic Jump, 
    input logic JR, 
    input logic [31:0] branch_address,
    input logic [31:0] jump_address,
    input logic [31:0] PCplus8,
    input logic [31:0] rs_content, 
    output logic [31:0] delay_addr 
  );

always@(posedge clk) begin
	//branch instructions
	if (Branch==2'b11) begin
		delay_addr <= branch_address;
	end
	//jump instructions (J, JAL)
	else if (Jump) begin
		delay_addr <= jump_address; 
	end
	//jump instructions (JR, JALR)
	else if (JR) begin
		delay_addr <= rs_content;
	end
	else begin
		delay_addr <= PCplus8; 
	end
end
endmodule
