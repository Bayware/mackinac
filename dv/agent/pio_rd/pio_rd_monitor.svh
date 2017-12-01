class pio_rd_monitor extends uvm_monitor;

  virtual pio_rd_if pio_rd_if_0;
  pio_rd_config pio_rd_config_0;
  string mon_name;

  uvm_analysis_port #(pio_rd_transaction) analysis_port;

  `uvm_component_utils(pio_rd_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_name = name;
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task probe_pins(pio_rd_transaction pio);

endclass

  function void pio_rd_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual pio_rd_if)::get(this, "", "pio_rd_if", pio_rd_if_0)) 
      `uvm_fatal("PIO_RD_MONITOR", "pio_rd_monitor not found");
    
    if (!(uvm_config_db#(pio_rd_config)::get(this,"","pio_rd_config",pio_rd_config_0)))
       `uvm_fatal("PIO_RD_MONITOR", "pio_rd_config not found")
    
    analysis_port = new("analysis_port", this);

  endfunction

  task pio_rd_monitor::run_phase(uvm_phase phase);

    pio_rd_transaction pio;

    forever begin
      pio = pio_rd_transaction::type_id::create("pio", this);
      probe_pins(pio);
      
      analysis_port.write(pio);
      repeat (1)  @(pio_rd_if_0.mon_cb);
    end
  endtask

  task pio_rd_monitor::probe_pins(pio_rd_transaction pio);

    bit [31:0] pio_rd_addr;

    while (pio_rd_if_0.mon_cb.avalid !== 1'b1) @(pio_rd_if_0.mon_cb);
    pio.addr = pio_rd_if_0.mon_cb.addr;
    while (pio_rd_if_0.mon_cb.aready !== 1'b1) @(pio_rd_if_0.mon_cb);
    @(pio_rd_if_0.mon_cb);
    while (pio_rd_if_0.mon_cb.dready !== 1'b1) @(pio_rd_if_0.mon_cb);
    while (pio_rd_if_0.mon_cb.dvalid !== 1'b1) @(pio_rd_if_0.mon_cb);
    pio.data = pio_rd_if_0.mon_cb.data;

    repeat (1) @(pio_rd_if_0.mon_cb);

  endtask
