
typedef uvm_sequencer #(special_packet) dma_sequencer;

 class dma_agent extends uvm_agent;

    virtual dma_if dma_if_0;

    dma_sequencer seqr;
    dma_driver drv;
    dma_monitor mon;

    uvm_analysis_port #(special_packet) analysis_port;

    `uvm_component_utils(dma_agent)

    function new(string name, uvm_component parent);
       super.new(name, parent);
    endfunction: new

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

 endclass

 function void dma_agent::build_phase(uvm_phase phase);
       super.build_phase(phase);

       uvm_config_db#(virtual dma_if)::get(this, "", "dma_if", dma_if_0);

       if (is_active==UVM_ACTIVE) begin
         seqr = dma_sequencer::type_id::create("seqr", this);
         drv =  dma_driver::type_id::create("drv", this);
         uvm_config_db#(virtual dma_if)::set(this, "drv", "dma_if", dma_if_0);
       end

       mon =  dma_monitor::type_id::create("mon", this);
       uvm_config_db#(virtual dma_if)::set(this, "mon", "dma_if", dma_if_0);

 endfunction

 function void dma_agent::connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      if (is_active==UVM_ACTIVE) 
        drv.seq_item_port.connect(seqr.seq_item_export);
      
      this.analysis_port = mon.analysis_port;

 endfunction
