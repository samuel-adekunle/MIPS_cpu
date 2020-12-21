module data_mem(
    input logic [31:0] address,
    input logic [31:0] WriteData,
    input logic MemWrite,
    input logic MemRead,
    input clk,
    output logic [31:0] ReadData
  );

  //data mem has capacity for 4096 32-bit entries.
  //array can start from 0
  //keep 0 as 0 in both memorys to start with
  logic [31:0] Mem[0:1024];
  logic [31:0] fullread;
  parameter DATA_INIT_FILE = "test_load.txt";

  initial
  begin
    integer i;
    /* Initialise to zero by default */
    for (i=0; i<4096; i++)
    begin
      Mem[i]=0;
    end
    /* Load contents from file if specified */
    if (DATA_INIT_FILE != "")
    begin
      $display("DATA_MEM : INIT : Loading DATA contents from %s", DATA_INIT_FILE);
      $readmemh(DATA_INIT_FILE, Mem,1);
    end
  end

  //we use byte addressing hence 2 LSB is ignored
  //single-cycle write
  always_ff @ (posedge clk)
  begin
    if (MemWrite&!MemRead)
    begin
      Mem[address>>2] <= WriteData;
    end
  end


  //assign ReadData = MemWrite ? WriteData : Mem[address>>2];
  //combinatorial read path
  always_comb
  begin
    if (MemRead&!MemWrite)
    begin
      ReadData = Mem[address>>2];
    end
  end

endmodule



