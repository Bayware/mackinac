  
typedef uvm_sequencer #(pio_wr_transaction) pio_wr_sequencer;

 class pio_wr_agent extends uvm_agent;

    `uvm_component_utils(pio_wr_agent)

    uvm_analysis_port #(pio_wr_transaction) analysis_port;

    virtual pio_wr_if pio_wr_if_0;

    pio_wr_sequencer    seqr;
    pio_wr_driver       drv;
    pio_wr_monitor      mon;
    pio_wr_adapter      adapter;

    string pio_name;

    function new(string name, uvm_component parent);
       super.new(name, parent);
       pio_name = name;
    endfunction: new

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

 endclass

 function void pio_wr_agent::build_phase(uvm_phase phase);
       super.build_phase(phase);

       uvm_config_db#(virtual pio_wr_if)::get(this, "", "pio_wr_if" ,pio_wr_if_0);

       if (is_active == UVM_ACTIVE) begin
         seqr = pio_wr_sequencer::type_id::create ("seqr",this);
         drv =  pio_wr_driver::type_id::create ("drv",this);
         uvm_config_db#(virtual pio_wr_if)::set(this, "drv", "pio_wr_if", pio_wr_if_0);
       end

       mon =  pio_wr_monitor::type_id::create({pio_name, "_mon"},this);
       uvm_config_db#(virtual pio_wr_if)::set(this, {pio_name, "_mon"}, "pio_wr_if", pio_wr_if_0);
       
       adapter = pio_wr_adapter::type_id::create( .name( "adapter" ) );

 endfunction: build_phase

 function void pio_wr_agent::connect_phase(uvm_phase phase);

      super.connect_phase(phase);

      if (is_active == UVM_ACTIVE) 
        drv.seq_item_port.connect(seqr.seq_item_export);

      this.analysis_port = mon.analysis_port;

 endfunction
