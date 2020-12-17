module select_datawrite(
    input logic [31:0] rt_content,
    input logic [31:0] data_readdata,
    input logic [5:0] opcode,
    input logic [1:0] data_address2LSB,
    input logic stall,
    output logic [31:0] data_writedata
  );

  logic [7:0] rt7_0;
  logic [15:0] rt15_0;


  always@(rt_content, data_readdata, opcode, data_address2LSB, stall)
  begin
    rt7_0 = rt_content[7:0];
    rt15_0 = rt_content[15:0];
    //SW
    if (opcode==6'h2b)
    begin
      data_writedata = rt_content;
    end
    //SB
    if (opcode==6'h28)
    begin
      if (stall!=1)
      begin
        case(data_address2LSB[1:0])
          3:
            data_writedata = {rt7_0, data_readdata[23:0]};
          2:
            data_writedata = {data_readdata[31:24], rt7_0, data_readdata[15:0]};
          1:
            data_writedata = {data_readdata[31:16], rt7_0, data_readdata[7:0]};
          0:
            data_writedata = {data_readdata[31:8], rt7_0};
        endcase
      end
    end
    //SH
    if (opcode==6'h29)
    begin
      if (stall !=1)
      begin
        case(data_address2LSB[1:0])
          2:
            data_writedata = {rt15_0, data_readdata[15:0]};
          0:
            data_writedata = {data_readdata[31:16], rt15_0};
        endcase
      end
    end
  end
endmodule
