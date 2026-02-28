class environment #(parameter DATA_WIDTH = 8);

  // Virtual interface
  virtual fifo_if vif;

  // Components
  generator   gen;
  driver      drv;
  monitor     mon;
  scoreboard  scb;

  // Mailboxes
  mailbox gen2drv;
  mailbox mon2scb;

  // -----------------------------
  // Constructor
  // -----------------------------
  function new(virtual fifo_if vif);
    this.vif = vif;

    // Create mailboxes
    gen2drv = new();
    mon2scb = new();

    // Create components
    gen = new(gen2drv);
    drv = new(vif, gen2drv);
    mon = new(vif, mon2scb);
    scb = new(mon2scb, vif);
  endfunction

  // -----------------------------
  // Run all components
  // -----------------------------
  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_none
  endtask

endclass