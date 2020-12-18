module avalon_mem(  ///idk need to understand properly
    input logic clk,
    input logic[31:0] address,
    input logic write,
    input logic read,
    output logic waitrequest,
    input logic[31:0] writedata,
    input logic[3:0] byteenable,
    output logic[31:0] readdata
  );

  parameter DATA_MEM_INIT_FILE = "test_load.txt";
  parameter INSTR_MEM_INIT_FILE = "test_load.txt";
  parameter BRANCH_JUMP_INIT_FILE = "test_loadj.txt";

  parameter incomplete = 0;
  parameter [31:0] rst = 32'hbfc00000;
  parameter [31:0] branch_max = 32'h0007fff<<2;
  parameter [31:0] branch_min = 32'hffff8000<<2;
  parameter [31:0] max_jump_addr = 32'hb3fffffc;
  parameter reset_offset = 60;
  parameter no_offset = 20; //11-20 jump backwards //same addrs
  parameter branch_back_offset = 21; //21-30 branch backwards maximum
  parameter branch_forward_offset = 31; //31-40 branch forwards maximum
  parameter jump_forward_offset = 41; //41-50 jump maximum

  //let 40 be the reset vector. around it can be other locations
  //instr mem has capacity for 4096 32-bit entries.
  //initialise the content at each address using a text file containing the instructions.
  logic [31:0] temp_read = 0;
  logic [31:0] temp_write = 0;
  logic [31:0] memory [0:1023];
  initial
  begin
    integer i;
    /* Initialise to zero by default */
    for (i=0; i<1024; i++)
    begin
      memory[i]=0;
    end
    /* Load contents from file if specified */
    if (DATA_MEM_INIT_FILE != "")
    begin
      $display("AVALON : INIT : Loading DATA contents from %s", DATA_MEM_INIT_FILE);
      $readmemh(DATA_MEM_INIT_FILE, memory,1, 10);
    end
    if (INSTR_MEM_INIT_FILE != "")
    begin
      $display("AVALON : INIT : Loading INSTR contents from %s", INSTR_MEM_INIT_FILE);
      $readmemh(INSTR_MEM_INIT_FILE, memory,reset_offset);
    end
    if (BRANCH_JUMP_INIT_FILE != "")
    begin
      $display("AVALON : INIT : Loading BRANCH/JUMP contents from %s", BRANCH_JUMP_INIT_FILE);
      $readmemh(BRANCH_JUMP_INIT_FILE, memory,11, 50);
    end
    waitrequest = 0;
  end
  integer x;
  //we use byte addressing hence 2 LSB is ignored
  //combi read path
  always @(posedge clk)
  begin
    if ((address>>2) <= no_offset)
    begin
      //jump back to 11-20 or data 0-10
      x = address>>2;
    end
    else if (address>=(rst+(branch_min))&&address<(rst+branch_min+40))
    begin
      x = ((address-(rst+branch_min))>>2)+branch_back_offset;
    end
    else if (address>=rst+branch_max && address <= rst+branch_max+40)
    begin
      x = ((address-rst-branch_max)>>2)+branch_forward_offset;
      //branch forwards to addresses 32'hbfc1fffc + 10 addr
    end
    else if (address>=max_jump_addr&& address<=max_jump_addr+40)
    begin
      //jump forwards to addresses 32'hc0000000 + 10 addr
      x = ((address-max_jump_addr)>>2)+jump_forward_offset;
    end
    else
    begin
      x = ((address-rst)>>2)+reset_offset;
    end
    if (read)
    begin
      //jump back to 11-20 or data 0-10
      temp_read = memory[x];
      //$display("address: %h, byteen %b temp read %h",address, byteenable, temp_read);
      if (byteenable == 0)
      begin
        readdata = temp_read;
      end
      else
      begin
        readdata[31:24] = byteenable[3] ? temp_read[31:24] : 8'b0;
        readdata[23:16] = byteenable[2] ? temp_read[23:16] : 8'b0;
        readdata[15:8] = byteenable[1] ? temp_read[15:8] : 8'b0;
        readdata[7:0] = byteenable[0] ? temp_read[7:0] : 8'b0;
      end

    end

    else if (write)
    begin
      temp_write = memory[x];
      if (byteenable == 0)
      begin
        memory[x] = writedata;
      end
      else
      begin
        temp_write = memory[x];
        temp_write[31:24] = byteenable[3] ? writedata[31:24]:temp_write[31:24];
        temp_write[23:16] = byteenable[2] ? writedata[23:16]:temp_write[23:16];
        temp_write[15:8] = byteenable[1] ? writedata[15:8]:temp_write[15:8];
        temp_write[7:0] = byteenable[0] ? writedata[7:0]:temp_write[7:0];
        memory[x] = temp_write;
        waitrequest = (read|write)&&(incomplete!=0);
      end
    end

  end

endmodule
