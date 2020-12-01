module mips_cpu_harvard_tb;
    timeunit 1ns / 10ps;

    // parameter RAM_INIT_FILE = "test/01-binary/addiu_1.txt";
    parameter DATA_MEM_INIT_FILE = "test/01-binary/addiu_1.txt";
    parameter INSTR_MEM_INIT_FILE = "test/01-binary/addiu_1.txt";
    parameter ANSWER_FILE = "test/4-reference/addiu_1.txt";

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
    // RAM_32x4096_harvard #(RAM_INIT_FILE) ramInst(.clk(clk), .instr_address(instr_address), .instr_readdata(instr_readdata), 
    // .data_write(data_write), .data_read(data_read),.data_address(data_address), .data_writedata(data_writedata),
    // .data_readdata(data_readdata));
    data_mem #(DATA_MEM_INIT_FILE) dataInst(.address(data_address), .WriteData(data_writedata), .MemWrite(data_write), 
    .MemRead(data_read), .clk(clk), .ReadData(data_readdata));
    instr_mem #(INSTR_MEM_INIT_FILE) instrInst(.address(instr_address), .clk(clk), .instr(instr_readdata));
    
    mips_cpu_harvard cpuInst(.clk(clk), .reset(reset), .active(active), .register_v0(register_v0),.clk_enable(clk_enable),
    .instr_address(instr_address), .instr_readdata(instr_readdata), .data_address(data_address), .data_write(data_write),
    .data_read(data_read), .data_writedata(data_writedata), .data_readdata(data_readdata));
    //read ans
    initial begin
        fd = $fopen(ANSWER_FILE, "r");
        x = $fscanf(fd, "%x", final_value);
        $fclose(fd);
    end
    // Generate clock
    initial begin
        clk=0;

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
            #10;
            clk = !clk;
        end
        // $display("CPU : V0 : %h", register_v0);
        // $display("Expected : %h", final_value);
        // if (register_v0==final_value) begin
        //     $display("success");
        // end
        $fatal(2, "Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    initial begin
        reset <= 0;
        //active<=1;
        @(posedge clk);
        reset <= 1;

        @(posedge clk);
        reset <= 0;
        
        @(posedge clk);
        assert(active==1)
        else $display("TB : CPU did not set active=1 after reset.");

        while (active) begin
            @(posedge clk);
            //$display("CPU : V0 :", register_v0);
            
        end

        $display("TB : finished; active=0");
        $display("CPU : V0 : %h", register_v0);
        $display("Expected : %h", final_value);
        if (register_v0==final_value) begin
            $display("success");
        end
        $finish;
        
        
    end
endmodule