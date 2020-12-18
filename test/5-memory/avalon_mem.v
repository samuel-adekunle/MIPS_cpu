module avalon_mem(
    input logic clk,
    input logic rst,
    input logic[31:0] address,
    input logic[3:0] byteenable,
    input logic[31:0] writedata,
    input logic read,
    input logic write,
    output logic[31:0] readdata,
    output logic waitrequest
  );
  typedef enum logic[1:0] {
            IDLE = 1,       // wait for incoming transaction
            FETCH = 2,      // process mem op
            HALT =3         // wait for bus controller to deassert read/write
          } state_t;

  parameter DATA_MEM_INIT_FILE = "test_loadk.txt";
  parameter INSTR_MEM_INIT_FILE = "test_loadk.txt";
  parameter BRANCH_JUMP_INIT_FILE = "test_loadj.txt";
  parameter [31:0] reset = 32'hbfc00000;
  parameter [31:0] branch_max = 32'h0007fff<<2;
  parameter [31:0] branch_min = 32'hffff8000<<2;
  parameter [31:0] max_jump_addr = 32'hb3fffffc;
  parameter reset_offset = 60;
  parameter no_offset = 20; //11-20 jump backwards //same addrs
  parameter branch_back_offset = 21; //21-30 branch backwards maximum
  parameter branch_forward_offset = 31; //31-40 branch forwards maximum
  parameter jump_forward_offset = 41; //41-50 jump maximum

  logic[1:0] state;
  logic[31:0] from_zero, reset_instr, branch_forward, branch_back, jump_forward;
  logic[31:0] temp_writedata, temp_olddata;
  logic[31:0] zero_addr, reset_addr, branch_forward_addr, branch_back_addr, jump_forward_addr;
  logic[1:0] byte_offset;
  integer x;
  logic [31:0] memory[0:1023];
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
      $readmemh(DATA_MEM_INIT_FILE, memory,1);
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
    readdata = 0;
    waitrequest = 0;
    state = IDLE;
  end



  assign zero_addr = address>>2;
  assign branch_forward_addr = ((address-reset-branch_max)>>2)+branch_forward_offset;
  assign branch_back_addr = ((address-(reset+branch_min))>>2)+branch_back_offset;
  assign jump_forward_addr = ((address-max_jump_addr)>>2)+jump_forward_offset;
  assign reset_addr = ((address-32'hbfc00000)>>2) +reset_offset;

  assign byte_offset = address[1:0];
  assign from_zero = memory[zero_addr];  //get data from the different mem sectors (convert address from byte addressing to word addressing)
  assign reset_instr = memory[reset_addr];
  assign branch_forward = memory[branch_forward_addr];
  assign branch_back = memory[branch_back_addr];
  assign jump_forward = memory[jump_forward_addr];

  assign temp_olddata = ((address>>2) <= no_offset) ? memory[address>>2] :
         (address>=(reset+(branch_min))&&address<(reset+branch_min+40)) ? memory[branch_back_addr] :
         (address>=reset+branch_max && address <= reset+branch_max+40) ? memory[branch_forward_addr] :
         (address>=max_jump_addr&& address<=max_jump_addr+40) ? memory[jump_forward_addr] :
         memory [((address-32'hbfc00000)>>2) +reset_offset];

  assign temp_writedata[7:0] = byteenable[0] ? writedata[7:0] : temp_olddata[7:0];    // byteenable for write operation
  assign temp_writedata[15:8] = byteenable[1] ? writedata[15:8] : temp_olddata[15:8];
  assign temp_writedata[23:16] = byteenable[2] ? writedata[23:16] : temp_olddata[23:16];
  assign temp_writedata[31:24] = byteenable[3] ? writedata[31:24] : temp_olddata[31:24];

  always @*
  begin     //check that all addresses are word aligned and that read/write are never asserted together
    if(read & write)
    begin
      $fatal(2,"Read and Write asserted together");
    end
    if(byte_offset!=0 && (read ^ write))
    begin
      $fatal(2,"Tried to access non-word-aligned address %h",address);
    end
  end

  always_comb
  begin       //set waitrequest as beign state dependent
    if(state==IDLE)
    begin       //waiting for incoming transaction, waitrequest asserts once an incoming transaction is detected
      waitrequest = read ^ write;
    end
    else if(state==FETCH)
    begin //performing mem op, assert waitrequest
      waitrequest = 1;
    end
    else if(state==HALT)
    begin  //deassert waitrequest to signal to bus controller that mem op is complete (data is ready for read)
      waitrequest = 0;
    end
  end

  always @(posedge clk)  //_ff
  begin
    if(state==IDLE)
    begin
      if(read ^ write)
      begin  //go to FETCH state when a read or write is requested
        state <= FETCH;
      end
    end
    else if(state==FETCH)
    begin
      // place mem op here
      if(read)
      begin
        //$display("be %b, reading from %h, simulating %d", byteenable, address, reset_addr);
        //read operation
        if ((address>>2) <= no_offset)
        begin
          //jump back to 11-20 or data 0-10
          readdata[7:0] <= byteenable[0] ? from_zero[7:0] : 8'h00;
          readdata[15:8] <= byteenable[1] ? from_zero[15:8] : 8'h00;
          readdata[23:16] <= byteenable[2] ? from_zero[23:16] : 8'h00;
          readdata[31:24] <= byteenable[3] ? from_zero[31:24] : 8'h00;
        end
        else if (address>=(reset+(branch_min))&&address<(reset+branch_min+40))
        begin
          readdata[7:0] <= byteenable[0] ? branch_back[7:0] : 8'h00;
          readdata[15:8] <= byteenable[1] ? branch_back[15:8] : 8'h00;
          readdata[23:16] <= byteenable[2] ? branch_back[23:16] : 8'h00;
          readdata[31:24] <= byteenable[3] ? branch_back[31:24] : 8'h00;
        end
        else if (address>=reset+branch_max && address <= reset+branch_max+40)
        begin
          readdata[7:0] <= byteenable[0] ? branch_forward[7:0] : 8'h00;
          readdata[15:8] <= byteenable[1] ? branch_forward[15:8] : 8'h00;
          readdata[23:16] <= byteenable[2] ? branch_forward[23:16] : 8'h00;
          readdata[31:24] <= byteenable[3] ? branch_forward[31:24] : 8'h00;
        end
        else if (address>=max_jump_addr&& address<=max_jump_addr+40)
        begin
          //jump forwards to addresses 32'hc0000000 + 10 addr
          readdata[7:0] <= byteenable[0] ? jump_forward[7:0] : 8'h00;
          readdata[15:8] <= byteenable[1] ? jump_forward[15:8] : 8'h00;
          readdata[23:16] <= byteenable[2] ? jump_forward[23:16] : 8'h00;
          readdata[31:24] <= byteenable[3] ? jump_forward[31:24] : 8'h00;
        end
        else
        begin
          readdata[7:0] <= byteenable[0] ? reset_instr[7:0] : 8'h00;
          readdata[15:8] <= byteenable[1] ? reset_instr[15:8] : 8'h00;
          readdata[23:16] <= byteenable[2] ? reset_instr[23:16] : 8'h00;
          readdata[31:24] <= byteenable[3] ? reset_instr[31:24] : 8'h00;
        end
      end
      else if(write)
      begin
        if ((address>>2) <= no_offset)
        begin
          //jump back to 11-20 or data 0-10
          
          memory[address>>2]<= temp_writedata;
        end
        else if (address>=(reset+(branch_min))&&address<(reset+branch_min+40))
        begin
          x = (((address-(reset+branch_min))>>2)+branch_back_offset);
          memory[x]<= temp_writedata;
        end
        else if (address>=reset+branch_max && address <= reset+branch_max+40)
        begin
          x = ((address-reset-branch_max)>>2)+branch_forward_offset;
          //branch forwards to addresses 32'hbfc1fffc + 10 addr
          memory[x]<= temp_writedata;
        end
        else if (address>=max_jump_addr&& address<=max_jump_addr+40)
        begin
          //jump forwards to addresses 32'hc0000000 + 10 addr
          x = ((address-max_jump_addr)>>2)+jump_forward_offset;
          memory[x]<= temp_writedata;
        end
        else
        begin
          memory[((address-reset)>>2)+reset_offset]<= temp_writedata;
        end
      end
      //end mem op
      state <= HALT;  //after mem op is done, go to HALT state to wait for bus controller to read data
    end
    else if(state==HALT)
    begin  //last cycle of transaction. After this transaction ends and transition back to IDLE state
      state <= IDLE;
    end
  end

endmodule