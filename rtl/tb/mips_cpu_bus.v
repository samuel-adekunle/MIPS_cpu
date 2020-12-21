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

  logic clk_enable;
  logic[31:0] data_address;
  logic[31:0] instr_address;
  logic[31:0] instr_readdata;
  logic[31:0] data_readdata;
  /*
    TODO - implementation of bus
    need to map address to data_address and instr_address (going to memory)
    need to map readdata (coming from mem) to instr_readdata and data_readdata
    need to map clk_enable to waitrequest
    need to control byteenable depending on the instruction
   */

  mips_cpu_harvard cpu (
                     .clk(clk),
                     .reset(reset),
                     .active(active),
                     .register_v0(register_v0),
                     .clk_enable(clk_enable),
                     .instr_address(instr_address),
                     .instr_readdata(instr_readdata),
                     .data_address(data_address),
                     .data_write(write),
                     .data_read(read),
                     .data_writedata(writedata),
                     .data_readdata(readdata)
                   );

endmodule