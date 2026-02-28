class driver;

  virtual fifo_if vif;
  mailbox gen2drv;
  transaction tr;

  // -----------------------------
  // Constructor
  // -----------------------------
  function new(virtual fifo_if vif, mailbox gen2drv);
    this.vif     = vif;
    this.gen2drv = gen2drv;
  endfunction

  // -----------------------------
  // Main run task
  // -----------------------------
  task run();
    forever begin
      gen2drv.get(tr);

      // -------------------------
      // Write operation
      // -------------------------
     if (tr.wr_en) begin
  do @(posedge vif.wr_clk); 
  while (vif.full || vif.wr_rst);

  // Now safe to write
  vif.wr_en   <= 1'b1;
  vif.data_in <= tr.data;
  @(posedge vif.wr_clk);
  vif.wr_en   <= 1'b0;

  $display("[DRV] WRITE data=0x%0h @ %0t", tr.data, $time);
end

      // -------------------------
      // Read operation
      // -------------------------
if (tr.rd_en) begin
  do @(posedge vif.rd_clk);
  while (vif.empty || vif.rd_rst);

  vif.rd_en <= 1'b1;
  @(posedge vif.rd_clk);
  vif.rd_en <= 1'b0;

  $display("[DRV] READ triggered @ %0t", $time);
end
      end
  endtask

endclass