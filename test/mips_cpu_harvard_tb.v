module mips_cpu_harvard_tb;
    timeunit 1ns / 10ps;
    parameter DATA_MEM_INIT_FILE = "test/01-binary/addiu_1.txt";
    parameter INSTR_MEM_INIT_FILE = "test/01-binary/addiu_1.txt";
    parameter ANSWER_FILE = "test/4-reference/addiu_1.txt";
    parameter BRANCH_JUMP_INIT_FILE = "test/5-memory/test_loadj.txt";

    parameter TIMEOUT_CYCLES = 10000;

    logic clk;
    logic reset;
    logic active;
    logic [31:0] register_v0;
    logic clk_enable;
    logic[31:0] instr_address;
    logic[31:0] instr_readdata;

    logic[31:0] data_address;
    logic data_write;
    logic data_read;
    logic[31:0] data_writedata;
    logic[31:0] data_readdata;
    logic [31:0] final_value;
    integer fd;
    integer x;

    data_mem #(DATA_MEM_INIT_FILE) dataInst(.address(data_address), 
                                            .WriteData(data_writedata), 
                                            .MemWrite(data_write), 
                                            .MemRead(data_read), 
                                            .clk(clk), 
                                            .ReadData(data_readdata));
    
    instr_mem #(INSTR_MEM_INIT_FILE, BRANCH_JUMP_INIT_FILE) instrInst(.address(instr_address),
                                                .clk(clk), 
                                                .instr(instr_readdata));
    
    mips_cpu_harvard cpuInst(.clk(clk),
                            .reset(reset),
                            .active(active),
                            .register_v0(register_v0),
                            .clk_enable(clk_enable),
                            .instr_address(instr_address), 
                            .instr_readdata(instr_readdata), 
                            .data_address(data_address),
                            .data_write(data_write),
                            .data_read(data_read),
                            .data_writedata(data_writedata), 
                            .data_readdata(data_readdata));
    //read ans
    initial begin
        fd = $fopen(ANSWER_FILE, "r");
        x = $fscanf(fd, "%x", final_value);
        $fclose(fd);
    end
    // Generate clock
    initial begin
        $dumpfile("help.vcd");
          $dumpvars(0, mips_cpu_harvard_tb);
        clk=0;

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
            #10;
            clk = !clk;
        end
        $display("TB : V0 : %h", register_v0);
        $display("TB : Expected : %h", final_value);
        if (register_v0==final_value) begin
            $display("TB : correct final value");
        end
        $fatal(2, "TB : Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    initial begin
        reset <= 1; 
        clk_enable <= 0;
        @(posedge clk);
	    clk_enable <= 1;
        reset <= 0;
        $display("TB : Reset reg and mem. reset: %b clk_en: %b memread:%b memwrite:%b", reset, clk_enable, data_read, data_write);
        //@(posedge clk); 
        // clk_enable <= 1; //undefined behaviours-when reset high, other components need to stop?
        // reset <= 0;
        @(posedge clk); 
         $display("TB : Begin. reset: %b clk_en: %b, active: %b memread:%b memwrite:%b", reset, clk_enable, active, data_read, data_write);
        @(posedge clk);
        assert(active==1)else $display("TB : active not set after reset.");

        while (active) begin
            @(posedge clk);
            //$display("TB : new edge: memread:%b memwrite:%b", data_read, data_write);
        end
        @(negedge clk)
        if (instr_readdata==0) //allow 0 to execute
        $display("TB : read at memory location 0");
        begin
            @(posedge clk);
            if (instr_readdata != 0) //it has read the next address, guaranteed to not be 0
            begin
                $fatal(2,"TB : Simulation did not stop after executing 0");
            end
        end

        $display("TB : finished; active=0");
        $display("TB : V0 : %h", register_v0);
        $display("TB : Expected : %h", final_value);
        if (register_v0==final_value) begin
            $display("TB : success");
        end
        $finish;
        
        
    end
endmodule
