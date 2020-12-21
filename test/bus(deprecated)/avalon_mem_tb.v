module avalon_mem_tb(
  );
     logic clk;
     logic rst;
     logic[31:0] address;
     logic[3:0] byteenable;
     logic[31:0] writedata;
     logic read;
     logic write;
     logic[31:0] readdata;
     logic waitrequest;


  initial
  begin
    read = 0;
    write = 1;
    writedata = 32'h12345678;
    byteenable = 4'b0010;
    $dumpfile("av_mem_Read.vcd");
    $dumpvars(0, avalon_mem_tb);
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
    address = 32'hBFC00000;
    repeat (10)
    begin
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      address=address+4;
    end
    address = 32'h0;
    repeat (21)
    begin
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      address=address+4;
      
    end
    address = 32'hbfbe0000;//branch back
    repeat (10)
    begin
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      address=address+4;
    end
    address = 32'hbfc1fffc; //branch forwards
    repeat (10)
    begin
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      address=address+4;
    end
    address = 32'hb3fffffc; //jump forwards
    repeat (10)
    begin
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      address=address+4;
    end
    address = 32'h0;
    @(posedge clk);
      @(posedge clk);
      #1; 
      @(posedge clk);
      #1;
    $display("Finished writing. Total time = %t", $time);
    read = 1;
    write = 0;
    byteenable = 4'b1111;
    address = 32'hBFC00000;
    repeat (10)
    begin
      @(posedge clk);
      #1;
      $display("instruction :%h at address %h", readdata, address);
      @(posedge clk);
      #1;
       $display("info %h \n", readdata);
      @(posedge clk);
      #1;
      address=address+4;
    end
    address = 32'h0;
    repeat (21)
    begin
      @(posedge clk);
      #1;
      $display("data/instruction :%h at address %h", readdata, address);
      @(posedge clk);
      #1;
       $display("info %h\n", readdata);
      @(posedge clk);
      #1;
      address=address+4;
      
    end
    address = 32'hbfbe0000;//branch back
    repeat (10)
    begin
      @(posedge clk);
      #1;
      $display("branch back instruction :%h at address %h", readdata, address);
      @(posedge clk);
      #1;
       $display("info %h \n", readdata);
      @(posedge clk);
      #1;
      address=address+4;
    end
    address = 32'hbfc1fffc; //branch forwards
    repeat (10)
    begin
      @(posedge clk);
      #1;
      $display("branch forwards instruction :%h at address %h", readdata, address);
      @(posedge clk);
      #1;
       $display("info %h\n", readdata);
      @(posedge clk);
      #1;
      address=address+4;
    end
    address = 32'hb3fffffc; //jump forwards
    repeat (10)
    begin
      @(posedge clk);
      #1;
      $display("jump forwards instruction :%h at address %h", readdata, address);

      @(posedge clk);
      #1;
       $display("info %h\n", readdata);
      @(posedge clk);
      #1;
      address=address+4;
    end
    address = 32'h0;
    @(posedge clk);
    $display("address %h", address);
      @(posedge clk);
      #1; 
      $display("info %h\n", readdata);
      @(posedge clk);
      #1;
    $display("Finished. Total time = %t", $time);
    $finish;
  end
  avalon_mem m(
              .address(address),
               .rst(rst),
               .clk(clk),
               .write(write),
               .read(read),
               .waitrequest(waitrequest),
               .writedata(writedata),
               .byteenable(byteenable),
               .readdata(readdata)
               );
endmodule

