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
    output logic pause
);

    //address alignment 
    logic [31:0] temp_address;
    logic[31:0] temp_writedata;   //added temp_writedata to handle the byte offsets for writedata
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
    if (data_write) begin
      case (temp_offset)
          2'b00: begin
            av_byteenable = 4'b1111; //read the whole word bc word aligned, offset = 0
            temp_writedata = data_writedata;
          end
          2'b01: begin
            av_byteenable = 4'b1110;
            temp_writedata = data_writedata << 8;
          end
          2'b10: begin
            av_byteenable = 4'b1100;
            temp_writedata = data_writedata << 16;
          end

          2'b11: begin
            av_byteenable = 4'b1000;
            temp_writedata = data_writedata << 24;
          end
      endcase
    end
    else begin
      av_byteenable = 4'b1111;
    end

  end





  //combinatorial

  always_comb
  begin
    if (state == IDLE)
    begin
      clk_enable = !(data_write ^ data_read | instr_read);    //changed clk_enable to be dependent on the harvard read signals
      pause = (data_write ^ data_read | instr_read); 
      if (data_write ^ data_read)
      begin
        av_address = temp_address;    //set av_address to word aligned address from data_address
        av_write = data_write;
        av_read = data_read;
        av_writedata = temp_writedata;
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
      pause = 1; 
      av_address = instr_address;
      av_write = 0;
      av_read = 1;
      av_writedata = 0;
    end



    else if (state == FETCH_DATA)
    begin
      clk_enable = 0;
      pause = 1; 
      av_address = temp_address;    //set av_address to word aligned address from data_address
      av_write = data_write;
      av_read = data_read;
      av_writedata = temp_writedata;
    end

    else if (state == INSTR_SET)
    begin
      clk_enable = 0;
      pause = 1; 
      av_address = instr_address; //feed instr address into avalon bus
      av_write = 0;
      av_read = 1;
      av_writedata = 0;
    end

    else if (state == HALTED)
    begin
      clk_enable = 1; //go into execution cycle
      pause = 0; 
      av_address = instr_address;
      av_read = 0;
      av_write = 0;
      av_writedata = 0;
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
    end



    else if (state == FETCH_DATA)
    begin
      if (av_waitrequest == 0)
      begin
        if(instr_read) begin  //instr_read now controls whether instruction is fetched after fetching data
          state <= INSTR_SET;
        end
        else begin
          state <= HALTED;
        end

        if (data_read == 1)   //changed av_read to data_read. Decisions are made based on the harvard inputs, not the avalon bus IOs
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

always@(posedge clk) begin
	    $display ("bus controller: state:%d", state);
end


endmodule
