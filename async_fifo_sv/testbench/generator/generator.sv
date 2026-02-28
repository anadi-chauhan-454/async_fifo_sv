class generator;

  // Mode selection: 0 = user-defined, 1 = random
  bit random_mode;

  // Queue of user-defined transactions
  transaction user_queue[$];

  // Mailbox to send transactions to driver
  mailbox gen2drv;

  // Number of random transactions
  int num_transaction = 10;

  // -----------------------------
  // Constructor
  // -----------------------------
  function new(mailbox gen2drv);
    this.gen2drv   = gen2drv;
    this.random_mode = 1'b1; // default random mode
  endfunction

  // -----------------------------
  // Add user-defined transaction
  // -----------------------------
  task add_user_defined_transaction(transaction tr);
    user_queue.push_back(tr);
  endtask

  // -----------------------------
  // Generator run task
  // -----------------------------
  task run();
    transaction tr;

    if (random_mode) begin
      $display("[GEN] Running random mode");

      repeat (num_transaction) begin
        tr = new();
        assert (tr.randomize() with {
          wr_en || rd_en;   // at least one must be enabled
        });

        tr.display("GEN");
        gen2drv.put(tr);
      end

    end else begin
      $display("[GEN] Running user-defined mode");

      foreach (user_queue[i]) begin
        user_queue[i].display("GEN");
        gen2drv.put(user_queue[i]);
      end
    end
  endtask

endclass