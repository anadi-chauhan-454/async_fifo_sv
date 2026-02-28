class monitor #(parameter DATA_WIDTH = 8);

  virtual fifo_if.Tb vif;
  mailbox mon2scb;

  // -----------------------------
  // Constructor
  // -----------------------------
  function new(virtual fifo_if.Tb vif, mailbox mon2scb);
    this.vif     = vif;
    this.mon2scb = mon2scb;
  endfunction

  // -----------------------------
  // Main run task
  // -----------------------------
  task run();
    fork
      monitor_write();
      monitor_read();
    join
  endtask

  // -----------------------------
  // Capture write transactions
  // -----------------------------
  task monitor_write();
    transaction tr;
    forever begin
      @(posedge vif.wr_clk);
      if (vif.wr_en && !vif.full) begin
        tr        = new();
        tr.wr_en  = 1'b1;
        tr.rd_en  = 1'b0;
        tr.data   = vif.data_in;

        mon2scb.put(tr.copy());
        $display("[MON] WRITE captured data=0x%0h @ %0t", tr.data, $time);
      end
    end
  endtask

  // -----------------------------
  // Capture read transactions
  // -----------------------------
  task monitor_read();
    transaction tr;
    forever begin
      @(posedge vif.rd_clk);
      if (vif.rd_en && !vif.empty) begin
        tr        = new();
        tr.wr_en  = 1'b0;
        tr.rd_en  = 1'b1;
        tr.data   = vif.data_out;

        mon2scb.put(tr.copy());
        $display("[MON] READ captured data=0x%0h @ %0t", tr.data, $time);
      end
    end
  endtask

endclass