module PC_1 ( 
	input logic[31:0] PCin, 
	input logic clk,  
	input logic reset,  
	input clk_enable,  
	output logic [31:0] PCout 
); 

always_ff @(posedge clk) begin 
	if (reset) begin 
		PCout <= 32'hBFC00000; //reset vector 
		//PCout <= 40; 
	end  
	else if (clk_enable) begin 
		PCout <= PCin + 4; 
	end 
	 
end  
always @(posedge clk) begin
	 $display("CPU : PC : %h", PCout);
end


endmodule 
