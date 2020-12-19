module mips_cpu_bus(
    /* Standard signals */
    input logic clk,
    input logic reset,
    output logic active,
    output logic[31:0] register_v0,

    /* Avalon memory mapped bus controller (master) */
    output logic[31:0] address,
    output logic write,
    output logic read,
    input logic waitrequest,
    output logic[31:0] writedata,
    output logic[3:0] byteenable,
    input logic[31:0] readdata
);

    // from harvard 
    logic [31:0] instr_address;
    logic [31:0] instr_readdata;
    logic [31:0]  data_address;
    logic [31:0]  data_writedata;
    logic [31:0]   data_readdata;
    logic data_write;
    logic data_read;
    wire clk_enable;
    logic pause; //from bus controller
    logic instr_read; //input to bus controller, same value as active? 

    initial begin 
	instr_read = 1; 
    end

    always_ff@(posedge clk) begin
	if (active == 0 & reset == 0) begin
	   instr_read <= 0;
	end
    end

    bus_controller busController(
        .clk(clk),
        .reset(reset),
        .clk_enable(clk_enable),
	.pause(pause), 

        .instr_address(instr_address),
        .instr_readdata(instr_readdata),
	.instr_read(instr_read), 
        .data_address(data_address),
        .data_write(data_write),
        .data_read(data_read),
        .data_writedata(data_writedata),
        .data_readdata(data_readdata),

        //avalon bus controller
        .av_address(address),
        .av_byteenable(byteenable),
        .av_read(read),
        .av_write(write),
        .av_waitrequest(waitrequest),
        .av_readdata(readdata),
        .av_writedata(writedata)
    );

    mips_cpu_harvard cpuHarvard(
        .clk(clk),
        .reset(reset),
        .active(active),
        .clk_enable(clk_enable),
        .register_v0(register_v0),
        .instr_address(instr_address),
        .instr_readdata(instr_readdata),
        .data_address(data_address),
        .data_write(data_write),
        .data_read(data_read),
        .data_writedata(data_writedata),
        .data_readdata(data_readdata),
	.pause(pause)
	//.instr_read(instr_read) 
    );
endmodule
