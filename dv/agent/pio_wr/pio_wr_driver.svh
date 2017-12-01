class pio_wr_driver extends uvm_driver #(pio_wr_transaction);

  virtual pio_wr_if  pio_wr_if_0;
  pio_wr_config pio_wr_config_0;

  `uvm_component_utils(pio_wr_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task drive_pins (pio_wr_transaction req);

endclass

  function void pio_wr_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual pio_wr_if)::get(this, "", "pio_wr_if", pio_wr_if_0)) 
      `uvm_fatal("PIO_WR_DRIVER", "pio_wr_if not found");

    if (!(uvm_config_db#(pio_wr_config)::get(this,"","pio_wr_config",pio_wr_config_0)))
       `uvm_fatal("PIO_WR_DRIVER", "pio_wr_config not found")

  endfunction

  task pio_wr_driver::run_phase(uvm_phase phase);

    super.run_phase(phase);
    
    pio_wr_if_0.drv_cb.addr  <= '0;
    pio_wr_if_0.drv_cb.avalid   <= '0;
    pio_wr_if_0.drv_cb.data    <= '0;
    pio_wr_if_0.drv_cb.dvalid   <= '0;
    pio_wr_if_0.drv_cb.bready   <= '0;
    pio_wr_if_0.drv_cb.strb   <= '0;

    forever begin
      seq_item_port.get_next_item(req);
      drive_pins(req);
      seq_item_port.item_done();
      req.end_tr();
    end

  endtask

  task pio_wr_driver::drive_pins(pio_wr_transaction req);

    int nready_cnt;
    int delay;

    delay = $urandom_range (pio_wr_config_0.min_delay, pio_wr_config_0.max_delay);
    repeat (delay) @ (pio_wr_if_0.drv_cb);

    pio_wr_if_0.drv_cb.avalid <= 1'b1;
    pio_wr_if_0.drv_cb.addr <= req.addr;

    nready_cnt = 0;
    while (pio_wr_if_0.mon_cb.aready !== 1'b1) begin
        if (nready_cnt==1000) `uvm_fatal ("PIO_WR_DRIVER", "aready not active before timeout");
        nready_cnt++;
        @(pio_wr_if_0.mon_cb);
    end

    repeat (2) @(pio_wr_if_0.mon_cb);

    pio_wr_if_0.drv_cb.avalid   <= 1'b0;
    pio_wr_if_0.drv_cb.dvalid   <= 1'b1;
    pio_wr_if_0.drv_cb.strb   <= 1'b1;
    pio_wr_if_0.drv_cb.data   <= req.data;

    nready_cnt = 0;
    while (pio_wr_if_0.mon_cb.dready !== 1'b1) begin
        if (nready_cnt==1000) `uvm_fatal ("PIO_WR_DRIVER", "dready not active before timeout");
        nready_cnt++;
        @(pio_wr_if_0.mon_cb);
    end

    pio_wr_if_0.drv_cb.bready   <= 1'b1;

    nready_cnt = 0;
    while (pio_wr_if_0.mon_cb.bvalid !== 1'b1) begin
        if (nready_cnt==1000) `uvm_fatal ("PIO_WR_DRIVER", "bvalid not active before timeout");
        nready_cnt++;
        @(pio_wr_if_0.mon_cb);
    	pio_wr_if_0.drv_cb.dvalid   <= 1'b0;
    	pio_wr_if_0.drv_cb.strb   <= 1'b0;
    end

    @(pio_wr_if_0.mon_cb);

    pio_wr_if_0.drv_cb.dvalid   <= 1'b0;
    pio_wr_if_0.drv_cb.strb   <= 1'b0;
    pio_wr_if_0.drv_cb.bready   <= 1'b0;

  endtask
