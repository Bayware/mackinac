class pio_rd_driver extends uvm_driver #(pio_rd_transaction);

  virtual pio_rd_if pio_rd_if_0;
  pio_rd_config pio_rd_config_0;

  `uvm_component_utils(pio_rd_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task drive_pins(pio_rd_transaction req);

endclass

  function void pio_rd_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual pio_rd_if)::get( this, "", "pio_rd_if", pio_rd_if_0)) 
      `uvm_fatal("PIO_RD_DRIVER", "pio_rd_if not found");

    if (!(uvm_config_db#(pio_rd_config)::get(this, "" ,"pio_rd_config" ,pio_rd_config_0)))
       `uvm_fatal("PIO_RD_DRIVER", "pio_rd_config not found")

  endfunction

  task pio_rd_driver::run_phase(uvm_phase phase);

    super.run_phase(phase);
   
    pio_rd_if_0.drv_cb.addr  <= '0;
    pio_rd_if_0.drv_cb.avalid   <= '0;
    pio_rd_if_0.drv_cb.dready    <= '0;

    forever begin
      seq_item_port.get_next_item(req);
      drive_pins (req);
      seq_item_port.item_done();
      req.end_tr();
    end

  endtask

  task pio_rd_driver::drive_pins (pio_rd_transaction req);

    int nready_cnt;
    int delay;

    delay = $urandom_range (pio_rd_config_0.min_delay, pio_rd_config_0.max_delay);
    repeat (delay) @ (pio_rd_if_0.drv_cb);

    pio_rd_if_0.drv_cb.avalid   <= 1'b1;
    pio_rd_if_0.drv_cb.addr  <= req.addr;

    nready_cnt = 0;
    while (pio_rd_if_0.mon_cb.aready !== 1'b1) begin
        if (nready_cnt == 1000) `uvm_fatal ("PIO_RD_DRIVER", "aready not active before timeout");
        nready_cnt++;
        @(pio_rd_if_0.mon_cb);
    end

    repeat (1) @(pio_rd_if_0.mon_cb);

    pio_rd_if_0.drv_cb.avalid   <= 1'b0;

    pio_rd_if_0.drv_cb.dready   <= 1'b1;
    repeat (1) @(pio_rd_if_0.mon_cb);

    nready_cnt = 0;
    while (pio_rd_if_0.mon_cb.dvalid !== 1'b1) begin
        if (nready_cnt == 1000) `uvm_fatal ("PIO_RD_DRIVER", "dvalid not active before timeout");
        nready_cnt++;
        repeat (1) @(pio_rd_if_0.mon_cb);
    end

    req.data = pio_rd_if_0.mon_cb.data;
    repeat (1) @(pio_rd_if_0.mon_cb);
    pio_rd_if_0.drv_cb.dready   <= 1'b0;
   
  endtask
