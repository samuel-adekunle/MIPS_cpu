module bus_controller(  //added instr_read input on harvard instruction port and associated functionality

    input logic clk,
    output logic[31:0] av_address,
    output logic av_write,
    output logic av_read,
    input logic av_waitrequest,
    output logic[31:0] av_writedata,
    output logic[3:0] av_byteenable,
    input logic[31:0] av_readdata,

    input logic reset,

    /* Clock enable signal */
    output logic clk_enable,

    /* Combinatorial read access to instructions */
    input logic[31:0]  instr_address,
    output logic[31:0]   instr_readdata,
    input logic instr_read,

    /* Combinatorial read and single-cycle write access to instructions */
    input logic[31:0]  data_address,
    input logic        data_write,
    input logic        data_read,
    input logic[31:0]  data_writedata,
    output logic[31:0]   data_readdata,

    /*to harvard*/
    output logic pause,

    /*from harvard*/
    input logic [1:0] store_type
  );

  //address alignment
  logic [31:0] temp_address;
  logic[31:0] temp_writedata;   //added temp_writedata to handle the byte offsets for writedata
  logic [1:0] temp_offset;
  logic[3:0] temp_byteenable;
  assign temp_address[31:2] = data_address[31:2];
  assign temp_address[1:0] = 2'b00;
  assign temp_offset = data_address[1:0];
  /* using enum to define CPU states. */

  typedef enum logic[2:0] {
            IDLE = 0,
            FETCH_INSTR = 1, //Read Instr from Mem
            FETCH_DATA = 2, //either Read or Write Data from Mem
            DATA_SET = 3,
            HALTED  = 4
          } state_t;

  logic[2:0] state;

  initial
  begin
    state = IDLE;
    instr_readdata = 0;
    data_readdata = 0;
    av_address = 0;
    av_read = 0;
    av_write = 0;
    av_writedata = 0;
    av_byteenable = 4'b1111;
    clk_enable = 1;
    pause = 0;
  end



  //case statement to set byteenable and word align writedata
  always_comb
  begin
    if (data_write)
    begin
      //temp_writedata = data_writedata;
      if (store_type == 2'b00)
      begin //sw
        temp_byteenable = 4'b1111; //read the whole word bc word aligned, offset = 0
        temp_writedata = data_writedata;
      end
      if (store_type == 2'b01)
      begin //sh
        case (temp_offset)
          2'b00:
          begin
            temp_byteenable = 4'b0011;
            temp_writedata = data_writedata;
          end
          2'b10:
          begin
            temp_byteenable = 4'b1100;
            temp_writedata = data_writedata << 16;
          end
        endcase
      end
      if (store_type == 2'b10)
      begin //sb
        case (temp_offset)
          2'b00:
          begin
            temp_byteenable = 4'b0001;
            temp_writedata = data_writedata;
          end
          2'b01:
          begin
            temp_byteenable = 4'b0010;
            temp_writedata = data_writedata << 8;
          end
          2'b10:
          begin
            temp_byteenable = 4'b0100;
            temp_writedata = data_writedata << 16;
          end

          2'b11:
          begin
            temp_byteenable = 4'b1000;
            temp_writedata = data_writedata << 24;
          end
        endcase
      end
    end
    else
    begin
      temp_byteenable = 4'b1111;
      av_byteenable = 4'b1111;
      temp_writedata = data_writedata;
    end

  end





  //combinatorial

  always_comb
  begin
    if (state == IDLE)
    begin
      clk_enable = !((data_write ^ data_read) | instr_read);    //dependent on the harvard read signals
      if ((data_write ^ data_read) & !instr_read)
      begin
        av_address = temp_address;    //set word aligned address from data_address
        av_write = data_write;
        av_read = data_read;
        av_writedata = temp_writedata;
        av_byteenable = temp_byteenable;
      end
      else
      begin
        av_address = instr_address;
        av_write = 0;
        av_read = 1; // read
        av_writedata = 0;
        av_byteenable = 4'b1111;
      end
    end

    else if (state == FETCH_INSTR)
    begin
      clk_enable = 0; //pause when fetching data
      av_address = instr_address;
      av_write = 0;
      av_read = 1;
      av_writedata = 0;
      av_byteenable = 4'b1111;
    end

    else if (state == FETCH_DATA)
    begin
      clk_enable = 0;
      av_address = temp_address;    //set av_address to word aligned address from data_address
      av_write = data_write;
      av_read = data_read;
      av_writedata = temp_writedata;
      av_byteenable = temp_byteenable;
    end

    else if (state == DATA_SET)
    begin
      clk_enable = 0; 
      av_address = temp_address; //feed instr address into avalon bus
      av_write = data_write;
      av_read = data_read;
      av_writedata = temp_writedata;
      av_byteenable = temp_byteenable;
    end

    else if (state == HALTED)
    begin
      clk_enable = 1; //go into execution cycle
      av_address = instr_address;
      av_read = 0;
      av_write = 0;
      av_writedata = 0;
      av_byteenable = 4'b1111;
    end
  end





  //states
  always_ff @(posedge clk)
  begin

    if (state == IDLE)
    begin
      if (data_write ^ data_read)
      begin
        state <= FETCH_DATA;
      end
      else if(instr_read)
      begin
        state <= FETCH_INSTR;
      end
      // else if (state == HALTED & (data_write ^ data_read))begin
      //   state <= FETCH_DATA;
      // end
    end



    else if (state == FETCH_DATA)
    begin
      if (av_waitrequest == 0)
      begin
        if(instr_read)
        begin  //instr_read now controls whether instruction is fetched after fetching data
          state <= DATA_SET;
        end
        else
        begin
          state <= HALTED;
        end

        if (data_read == 1)   //changed av_read to data_read. Decisions are made based on the harvard inputs, not the avalon bus IOs
        begin
          data_readdata <= av_readdata;
        end
      end
    end

    else if (state == DATA_SET)
    begin
      state <= FETCH_INSTR;
    end

    else if (state == FETCH_INSTR)
    begin
      if (av_waitrequest == 0)
      begin
        state <= HALTED;
        if (instr_read == 1)    //changed av_read to instr_read
        begin
          instr_readdata <= av_readdata;
        end
      end
    end



    else if (state == HALTED)
    begin
      state <= IDLE;
    end


  end

  always@(posedge clk)
  begin
    $display ("bus controller: state:%d", state);
    $display ("data address:%h, temp_address:%h", data_address,temp_address);
    $display ("clk_E:%d \n", clk_enable);
    $display ("data write:%d, data read :%d byteenable:%b\n", data_write, data_read, av_byteenable);
  end


endmodule
