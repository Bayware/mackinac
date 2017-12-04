typedef uvm_sequencer #(pio_rd_transaction) pio_rd_sequencer;

 class pio_rd_agent extends uvm_agent;

    virtual pio_rd_if pio_rd_if_0;

    pio_rd_sequencer    seqr;
    pio_rd_driver       drv;
    pio_rd_monitor      mon;

    string pio_name;

    uvm_analysis_port #(pio_rd_transaction) analysis_port;

    `uvm_component_utils(pio_rd_agent)

    function new(string name, uvm_component parent);
       super.new(name, parent);
       pio_name = name;
    endfunction: new

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

 endclass

 function void pio_rd_agent::build_phase(uvm_phase phase);
       super.build_phase(phase);

       uvm_config_db#(virtual pio_rd_if)::get(this, "", "pio_rd_if" ,pio_rd_if_0);

       if (is_active == UVM_ACTIVE) begin
         seqr = pio_rd_sequencer::type_id::create ("seqr",this);
         drv =  pio_rd_driver::type_id::create ("drv",this);
         uvm_config_db#(virtual pio_rd_if)::set(this, "drv", "pio_rd_if", pio_rd_if_0);
       end

       mon =  pio_rd_monitor::type_id::create({pio_name, "_mon"},this);
       uvm_config_db#(virtual pio_rd_if)::set(this, {pio_name, "_mon"}, "pio_rd_if", pio_rd_if_0);

 endfunction: build_phase

 function void pio_rd_agent::connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      if (is_active == UVM_ACTIVE) 
        drv.seq_item_port.connect(seqr.seq_item_export);

      this.analysis_port = mon.analysis_port;

 endfunction
