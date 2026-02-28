module async_fifo #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 4
)(
  // Write domain
  input  logic                   wr_clk,
  input  logic                   wr_rst,
  input  logic                   wr_en,
  input  logic [DATA_WIDTH-1:0]  data_in,
  output logic                   full,

  // Read domain
  input  logic                   rd_clk,
  input  logic                   rd_rst,
  input  logic                   rd_en,
  output logic [DATA_WIDTH-1:0]  data_out,
  output logic                   empty
);

  localparam DEPTH = 1 << ADDR_WIDTH;

  // FIFO memory
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Binary and Gray pointers
  logic [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_gray;
  logic [ADDR_WIDTH:0] rd_ptr_bin, rd_ptr_gray;

  // Synchronized Gray pointers
  logic [ADDR_WIDTH:0] rd_ptr_gray_sync_wr1, rd_ptr_gray_sync_wr2;
  logic [ADDR_WIDTH:0] wr_ptr_gray_sync_rd1, wr_ptr_gray_sync_rd2;

  // -----------------------------
  // Write clock domain
  // -----------------------------
  always_ff @(posedge wr_clk or posedge wr_rst) begin
    if (wr_rst) begin
      wr_ptr_bin           <= '0;
      wr_ptr_gray          <= '0;
      rd_ptr_gray_sync_wr1 <= '0;
      rd_ptr_gray_sync_wr2 <= '0;
    end else begin
      rd_ptr_gray_sync_wr1 <= rd_ptr_gray;
      rd_ptr_gray_sync_wr2 <= rd_ptr_gray_sync_wr1;

      if (wr_en && !full) begin
        mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= data_in;
        wr_ptr_bin  <= wr_ptr_bin + 1'b1;
        wr_ptr_gray <= (wr_ptr_bin + 1'b1) ^ ((wr_ptr_bin + 1'b1) >> 1);
      end
    end
  end

  // -----------------------------
  // Read clock domain
  // -----------------------------
  always_ff @(posedge rd_clk or posedge rd_rst) begin
    if (rd_rst) begin
      rd_ptr_bin           <= '0;
      rd_ptr_gray          <= '0;
      wr_ptr_gray_sync_rd1 <= '0;
      wr_ptr_gray_sync_rd2 <= '0;
      data_out             <= '0;
    end else begin
      wr_ptr_gray_sync_rd1 <= wr_ptr_gray;
      wr_ptr_gray_sync_rd2 <= wr_ptr_gray_sync_rd1;

      if (rd_en && !empty) begin
        data_out   <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
        rd_ptr_bin <= rd_ptr_bin + 1'b1;
        rd_ptr_gray<= (rd_ptr_bin + 1'b1) ^ ((rd_ptr_bin + 1'b1) >> 1);
      end
    end
  end

  // -----------------------------
  // Gray to Binary function
  // -----------------------------
  function automatic [ADDR_WIDTH:0] gray_to_bin (
    input [ADDR_WIDTH:0] gray
  );
    integer i;
    begin
      gray_to_bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
      for (i = ADDR_WIDTH-1; i >= 0; i = i - 1)
        gray_to_bin[i] = gray_to_bin[i+1] ^ gray[i];
    end
  endfunction

  // -----------------------------
  // Binary converted pointers
  // -----------------------------
  wire [ADDR_WIDTH:0] wr_bin_next;
  wire [ADDR_WIDTH:0] rd_bin_sync;

  assign wr_bin_next = gray_to_bin(wr_ptr_gray);
  assign rd_bin_sync = gray_to_bin(rd_ptr_gray_sync_wr2);

  // -----------------------------
  // FULL condition
  // -----------------------------
  assign full =
    (wr_bin_next[ADDR_WIDTH]     != rd_bin_sync[ADDR_WIDTH]) &&
    (wr_bin_next[ADDR_WIDTH-1:0] == rd_bin_sync[ADDR_WIDTH-1:0]);

  // -----------------------------
  // EMPTY condition
  // -----------------------------
  assign empty =
    (gray_to_bin(rd_ptr_gray) == gray_to_bin(wr_ptr_gray_sync_rd2));

endmodule
