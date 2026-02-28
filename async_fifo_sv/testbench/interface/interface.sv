interface fifo_if #(parameter DATA_WIDTH = 8) 
  ( 
    input logic wr_clk, 
    input logic rd_clk 
  ); //DUT Input 
  logic [DATA_WIDTH-1:0] data_in; 
  logic wr_rst, wr_en; 
  logic rd_rst, rd_en; 
  //DUT Output logic 
  logic [DATA_WIDTH-1:0] data_out; 
  logic full,empty; 
  
  modport Tb( 
    input full,empty,data_out, 
    input wr_clk,rd_clk, 
    output data_in,wr_rst,rd_rst,wr_en,rd_en 
  ); 
endinterface