class pio_wr_monitor extends uvm_monitor;

  virtual pio_wr_if pio_wr_if_0;
  pio_wr_config pio_wr_config_0;
  string mon_name;
  
  uvm_analysis_port #(pio_wr_transaction) analysis_port;

  `uvm_component_utils(pio_wr_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_name = name;
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task probe_pins(pio_wr_transaction pio);

endclass

  function void pio_wr_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual pio_wr_if)::get(this, "", "pio_wr_if", pio_wr_if_0)) 
      `uvm_fatal("PIO_WR_MONITOR", "pio_wr_monitor not found");
    
    if (!(uvm_config_db#(pio_wr_config)::get(this, "", "pio_wr_config", pio_wr_config_0)))
       `uvm_fatal("PIO_WR_MONITOR", "pio_wr_config not found")
   
    analysis_port = new("analysis_port", this);

  endfunction

  task pio_wr_monitor::run_phase(uvm_phase phase);

    pio_wr_transaction pio;

    forever begin
      pio = pio_wr_transaction::type_id::create("pio", this);
      probe_pins(pio);
      analysis_port.write(pio);
      repeat (1)  @(pio_wr_if_0.mon_cb);
    end
  endtask

  task pio_wr_monitor::probe_pins(pio_wr_transaction pio);

    while (pio_wr_if_0.mon_cb.avalid !== 1'b1) @(pio_wr_if_0.mon_cb);
    pio.addr = pio_wr_if_0.mon_cb.addr;
    while (pio_wr_if_0.mon_cb.aready !== 1'b1) @(pio_wr_if_0.mon_cb);
    
    pio.data = pio_wr_if_0.mon_cb.data;
    while (pio_wr_if_0.mon_cb.dvalid !== 1'b1) @(pio_wr_if_0.mon_cb);
    while (pio_wr_if_0.mon_cb.dready !== 1'b1) @(pio_wr_if_0.mon_cb);

    repeat (1)  @(pio_wr_if_0.mon_cb);

  endtask
