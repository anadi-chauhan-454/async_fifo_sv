`timescale 1ns/1ps

`include "interface.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "environment.sv"

module top;

  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 4;

  logic wr_clk = 0;
  logic rd_clk = 0;

  // Interface
  fifo_if #(DATA_WIDTH) intf (
    .wr_clk (wr_clk),
    .rd_clk (rd_clk)
  );

  // Environment
  environment #(DATA_WIDTH) env;

  // Clocks
  always #5 wr_clk = ~wr_clk;
  always #7 rd_clk = ~rd_clk;

  // DUT
  async_fifo #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
  ) dut (
    .data_in  (intf.data_in),
    .wr_en    (intf.wr_en),
    .wr_clk   (intf.wr_clk),
    .wr_rst   (intf.wr_rst),
    .full     (intf.full),
    .data_out (intf.data_out),
    .rd_en    (intf.rd_en),
    .rd_clk   (intf.rd_clk),
    .rd_rst   (intf.rd_rst),
    .empty    (intf.empty)
  );

  // -----------------------------
  // RESET TEST
  // -----------------------------
//   task automatic test_reset_check();
//     env.gen.random_mode = 0;

//     intf.wr_rst  = 1'b1;
//     intf.rd_rst  = 1'b1;
//     intf.wr_en   = 1'b0;
//     intf.rd_en   = 1'b0;
//     intf.data_in = '0;

//     #20;
//     intf.wr_rst = 1'b0;
//     intf.rd_rst = 1'b0;

//     #20;
//     $display("[TB] Reset completed successfully");

//     // Basic checks
//     if (intf.empty !== 1'b1)
//       $error("[TB] FIFO not empty after reset");

//     if (intf.full !== 1'b0)
//       $error("[TB] FIFO full after reset");
//   endtask
  
  task automatic test_single_write_read();
  transaction t;

  // Disable random mode
  env.gen.random_mode = 0;

  $display("[TEST2] Single write then single read test");

  // -----------------
  // Single WRITE
  // -----------------
  t = new();
  t.wr_en = 1;
  t.rd_en = 0;
  t.data  = 8'd42;

  env.gen.add_user_defined_transaction(t);

  // -----------------
  // Single READ
  // -----------------
  t = new();
  t.wr_en = 0;
  t.rd_en = 1;

  env.gen.add_user_defined_transaction(t);

endtask

  // -----------------------------
  // TEST CONTROL (ONLY ONE)
  // -----------------------------
  initial begin
    env = new(intf);

    // Test 1: Reset
//     test_reset_check();
    
    test_single_write_read();
    

    // Test 2: Normal traffic
    env.run();

    #10000;
    $display("[TB] Simulation finished");
    $finish;
  end

  // -----------------------------
  // Waveform dump
  // -----------------------------
  initial begin
    $dumpfile("fifo_reset1.vcd");
    $dumpvars(0, top);
    #1 $dumpflush;
  end

endmodule
