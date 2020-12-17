module data_mem_tb(
  );
  logic [31:0] address;
  logic clk;
  logic [31:0] WriteData;
  logic MemWrite;
  logic MemRead;
  logic [31:0] ReadData;
  integer x;

  initial
  begin
    MemWrite = 0;
    $dumpfile("data_mem_Read.vcd");
    $dumpvars(0, data_mem_tb);
    clk = 0;
    #1
     repeat (1000)
     begin
       #1 clk = !clk;
     end
     $fatal(2, "Fail : test-bench timed out without positive exit.");
  end
  initial
  begin
    address = 0;
    MemRead = 1;
    repeat (100)
    begin
      @(posedge clk);
      #1;
      $display("data :%h at address %h", ReadData, address);
      address=address+4;
    end
    MemWrite = 1;
    address = 0;
    x = 10;
    repeat (100)
    begin
      WriteData = x;
      @(posedge clk);
      #1;
      $display("writing :%h at address %h", WriteData, address);
      address=address+4;
      x =x+1847383;
    end
    address = 0;
    MemWrite = 0;
    MemRead = 1;
    x =10;
    repeat (100)
    begin
      @(posedge clk);
      #1;
      if (x == ReadData)
      begin
        $display("Reading :%h at address %h", ReadData, address);
        assert(ReadData == x)else
                $fatal(1, "did not read");
      end
      address=address+4;
      x =x+1847383;
    end
    $display("Finished. Total time = %t", $time);
    $finish;
  end
  data_mem m(
             .address(address), .clk(clk), .ReadData(ReadData), .WriteData(WriteData),
             .MemWrite(MemWrite), .MemRead(MemRead)
           );
endmodule

