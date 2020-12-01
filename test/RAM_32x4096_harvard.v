module RAM_32x4096_harvard(
    input logic clk,
    input logic[31:0] instr_address,
    output logic[31:0] instr_readdata,
    input logic data_write,
    input logic data_read,
    input logic[31:0] data_address,
    input logic[31:0] data_writedata,
    output logic[31:0] data_readdata
);
    parameter RAM_INIT_FILE = "";

    reg [31:0] memory [0:4095];

    initial begin
        integer i;
        /* Initialise to zero by default */
        for (i=0; i<4096; i++) begin
            memory[i]=0;
        end
        /* Load contents from file if specified */
        if (RAM_INIT_FILE != "") begin
            $display("RAM : INIT : Loading RAM contents from %s", RAM_INIT_FILE);
            $readmemh(RAM_INIT_FILE, memory);
        end
    end

    /* Combinatorial read path. */
    assign data_readdata = data_read ? memory[data_address] : 32'hxxxx;
    assign instr_readdata = memory[instr_address];

    /* Synchronous write path */
    always @(posedge clk) begin

        if (data_write) begin
            memory[data_address] <= data_writedata;
        end
    end
endmodule