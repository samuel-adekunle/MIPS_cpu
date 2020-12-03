module PC_1 ( 
	input logic[31:0] PCin, 
	input logic clk,  
	input logic reset,  
	input clk_enable,  
	output logic [31:0] PCout 
); 

 

always_ff @(posedge clk) begin 
	if (reset) begin 
<<<<<<< HEAD
		PCout <= 32'hBFC00000; //reset vector 
=======
		PCin <= 32'hBFC00000; //reset vector 
>>>>>>> 60ff0e278f2a0e7d31675698b205792b6a01ab25
	end  
	else if (clk_enable) begin 
		PCout <= PCin + 4; 
	end  
end  


endmodule 