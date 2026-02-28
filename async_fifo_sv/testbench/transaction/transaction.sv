class transaction;

  // Data to write or captured during read
  rand bit [7:0] data;

  // Control signals
  rand bit wr_en;
  rand bit rd_en;

  // Expected data for scoreboard comparison
  bit [7:0] expected_data;

  // -----------------------------
  // Constructor
  // -----------------------------
  function new();
    data          = 8'h00;
    wr_en         = 1'b0;
    rd_en         = 1'b0;
    expected_data = 8'h00;
  endfunction

  // -----------------------------
  // Display transaction
  // -----------------------------
  function void display(string tag = "");
    $display("[%s] TX: wr_en=%0b rd_en=%0b data=0x%0h expected=0x%0h",
              tag, wr_en, rd_en, data, expected_data);
  endfunction

  // -----------------------------
  // Clone transaction (used in monitor)
  // -----------------------------
  function transaction copy();
    transaction t = new();
    t.data          = this.data;
    t.wr_en         = this.wr_en;
    t.rd_en         = this.rd_en;
    t.expected_data = this.expected_data;
    return t;
  endfunction

  // -----------------------------
  // Compare with another transaction
  // -----------------------------
  function bit compare(transaction t);
    return (this.data == t.expected_data);
  endfunction

endclass