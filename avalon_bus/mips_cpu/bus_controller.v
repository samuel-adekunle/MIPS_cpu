module bus_controller(

    input logic clk,
    output logic[31:0] av_address,
    output logic av_write,
    output logic av_read,
    input logic av_waitrequest,
    output logic[31:0] av_writedata,
    output logic[3:0] av_byteenable,
    input logic[31:0] av_readdata,

    output logic         reset,
    input logic        active,
    input logic[31:0]  register_v0,

    /* Clock enable signal */
    output logic         clk_enable,

    /* Combinatorial read access to instructions */
    input logic[31:0]  instr_address,
    output logic[31:0]   instr_readdata,

    /* Combinatorial read and single-cycle write access to instructions */
    input logic[31:0]  data_address,
    input logic        data_write,
    input logic        data_read,
    input logic[31:0]  data_writedata,
    output logic[31:0]   data_readdata,

   //deactivate harvard
   output logic pause
);
    //address alignment 
    logic [31:0] temp_address;
    logic [1:0] temp_offset;
    assign temp_address[31:2] = data_address[31:2];
    assign temp_address[1:0] = 2'b00;
    assign temp_offset = data_address[1:0];

  /* using enum to define CPU states. */
  typedef enum logic[2:0] {
            IDLE = 0,
            FETCH_INSTR = 1, //Read Instr from Mem
            FETCH_DATA = 2, //either Read or Write Data from Mem
            INSTR_SET = 3,
            HALTED  = 4
          } state_t;

  logic[2:0] state;

  initial
  begin
    state = IDLE;
    // active = 0;
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

  //case statement to set byteenable
  always_comb
  begin
    case (temp_offset)
        2'b00: begin
          av_byteenable = 4'b1111; //read the whole word bc word aligned, offset = 0
        end
        2'b01: begin
          av_byteenable = 4'b1110;
        end
        2'b10: begin
          av_byteenable = 4'b1100;
        end
        2'b11: begin
          av_byteenable = 4'b1000;
        end
    endcase
  end


  //combinatorial
  always_comb
  begin
    if (state == IDLE)
    begin
      clk_enable = 0;
      pause = 0; 
      if (data_write ^ data_read)
      begin
        av_address = data_address;
        av_write = data_write;
        av_read = data_read;
        av_writedata = data_writedata;
      end
      else 
      begin
        av_address = instr_address;
        av_write = 0;
        av_read = 1; // read 
        av_writedata = 0;
      end
    end

    else if (state == FETCH_INSTR)
    begin
      clk_enable = 0; //pause when fetching data
      av_address = instr_address;
      av_write = 0;
      av_read = 1;
      av_writedata = 0;
      pause = 0; 
    end

    else if (state == FETCH_DATA)
    begin
      clk_enable = 0;
      av_address = data_address;
      av_write = data_write;
      av_read = data_read;
      av_writedata = data_writedata;
    end

    else if (state == INSTR_SET)
    begin
      clk_enable = 0;
      av_address = instr_address; //feed instr address into avalon bus
      av_write = 0;
      av_read = 1;
      av_writedata = 0;
    end

    else if (state == HALTED)
    begin
      clk_enable = 1; //go into execution cycle
      av_address = instr_address;
      av_read = 0;
      av_write = 0;
      av_writedata = 0;
      pause = 1; 
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
      else
      begin
        state <= FETCH_INSTR;
      end
    end

    else if (state == FETCH_DATA)
    begin
      if (av_waitrequest == 0)
      begin
        state <= INSTR_SET;
        if (av_read == 1)
        begin
          case (temp_offset)
          2'b00: begin
            data_readdata <= av_readdata; 
          end
          2'b01: begin
            data_readdata <= av_readdata >> 8; //shift right by 1 byte
          end
          2'b10: begin
            data_readdata <= av_readdata >> 16;
          end
          2'b11: begin
            data_readdata <= av_readdata >> 24;
          end
          endcase 
        end

        if (av_write == 1)
        begin
          case (temp_offset)
          2'b00: begin
            av_writedata <= data_writedata; 
          end
          2'b01: begin
            av_writedata <= data_writedata >> 8; //shift right by 1 byte
          end
          2'b10: begin
            av_writedata <= data_writedata >> 16;
          end
          2'b11: begin
            av_writedata <= data_writedata >> 24;
          end
          endcase 
        end
      end
    end

    else if (state == INSTR_SET)
    begin
      state <= FETCH_INSTR;
    end

    else if (state == FETCH_INSTR)
    begin
      if (av_waitrequest == 0)
      begin
        state <= HALTED;
        if (av_read == 1)
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
endmodule
