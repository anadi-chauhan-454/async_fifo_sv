class scoreboard #(parameter DATA_WIDTH = 8);

  // Queue holding expected FIFO data
  bit [DATA_WIDTH-1:0] expected_q[$];

  // Mailbox from monitor
  mailbox mon2scb;

  // Virtual interface (optional, kept for extensibility)
  virtual fifo_if.Tb vif;

  // -----------------------------
  // Constructor
  // -----------------------------
  function new(mailbox mon2scb, virtual fifo_if.Tb vif);
    this.mon2scb = mon2scb;
    this.vif     = vif;
  endfunction

  // -----------------------------
  // Main run task
  // -----------------------------
  task run();
    transaction tr;
    bit [DATA_WIDTH-1:0] expected_val;

    forever begin
      mon2scb.get(tr);

      // -------------------------
      // WRITE observed
      // -------------------------
      if (tr.wr_en && !tr.rd_en) begin
        expected_q.push_back(tr.data);
        $display("[SCB] WRITE : expected_q <= 0x%0h", tr.data);
      end

      // -------------------------
      // READ observed
      // -------------------------
      else if (tr.rd_en && !tr.wr_en) begin
        if (expected_q.size() > 0) begin
          expected_val = expected_q.pop_front();

          if (tr.data !== expected_val) begin
            $display("[SCB][FAIL] READ mismatch exp=0x%0h got=0x%0h",
                      expected_val, tr.data);
          end
          else begin
            $display("[SCB][PASS] READ match data=0x%0h", tr.data);
          end
        end
        else begin
          $display("[SCB][WARN] Underflow: read with empty expected queue");
        end
      end

    end
  endtask

endclass