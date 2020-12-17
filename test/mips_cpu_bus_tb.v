module mips_cpu_bus_tb;
    timeunit 1ns / 10ps;

    // parameter RAM_INIT_FILE = "test/01-binary/addiu_1.txt";
    parameter DATA_MEM_INIT_FILE = "test/01-binary/addiu_1.txt";
    parameter INSTR_MEM_INIT_FILE = "test/01-binary/addiu_1.txt";
    parameter ANSWER_FILE = "test/4-reference/addiu_1.txt";
    parameter BRANCH_JUMP_INIT_FILE = "test/5-memory/test_loadj.txt";

    parameter TIMEOUT_CYCLES = 10000;
    /* Standard signals */
    logic clk;
    logic reset;
    logic active;
    logic [31:0] register_v0;
    logic clk_enable;
    /* Avalon memory mapped bus controller (master) */
    logic[31:0] address;
    logic write;
    logic read;
    logic waitrequest;
    logic[31:0] writedata;
    logic[3:0] byteenable;
    logic[31:0] readdata;
    integer fd;
    integer x;
    
    avalon_mem #(DATA_MEM_INIT_FILE, INSTR_MEM_INIT_FILE, BRANCH_JUMP_INIT_FILE) avalonInst(.address(address),
                                                .clk(clk), 
                                                .write(write),
                                                .read(read),
                                                .waitrequest(waitrequest),
                                                .writedata(writedata),
                                                .byteenable(byteenable),
                                                .readdata(readdata));
    
    mips_cpu_bus cpuInst(.clk(clk),
                            .reset(reset),
                            .active(active),
                            .register_v0(register_v0),
                            .address(address), 
                            .write(write),
                            .read(read),
                            .waitrequest(waitrequest),
                            .writedata(writedata),
                            .byteenable(byteenable),
                            .readdata(readdata));
    //read ans
    initial begin
        fd = $fopen(ANSWER_FILE, "r");
        x = $fscanf(fd, "%x", final_value);
        $fclose(fd);
    end
    // Generate clock
    initial begin
        $dumpfile("help.vcd");
          $dumpvars(0, mips_cpu_bus_tb);
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
        $display("TB : Reset reg and mem. reset: %b clk_en: %b", reset, clk_enable);
        //@(posedge clk); 
        // clk_enable <= 1; //undefined behaviours-when reset high, other components need to stop?
        // reset <= 0;
        @(posedge clk); 
         $display("TB : Begin. reset: %b clk_en: %b, active: %b", reset, clk_enable, active);
        @(posedge clk);
        assert(active==1)else $display("TB : active not set after reset.");

        while (active) begin
            @(posedge clk);
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
