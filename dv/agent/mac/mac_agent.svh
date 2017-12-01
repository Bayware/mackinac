
typedef uvm_sequencer #(special_packet) mac_sequencer;

 class mac_agent extends uvm_agent;

    virtual mac_if mac_if_0;

    mac_sequencer seqr;
    mac_driver drv;
    mac_monitor mon;

    uvm_analysis_port #(special_packet) analysis_port;

    `uvm_component_utils(mac_agent)

    function new(string name, uvm_component parent);
       super.new(name, parent);
    endfunction: new

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

 endclass

 function void mac_agent::build_phase(uvm_phase phase);
       super.build_phase(phase);

       uvm_config_db#(virtual mac_if):: get(this, "", "mac_if", mac_if_0);

       if (is_active == UVM_ACTIVE) begin
         seqr = mac_sequencer::type_id::create ("seqr",this);
         drv =  mac_driver::type_id::create ("drv",this);
         uvm_config_db#(virtual mac_if)::set(this, "drv", "mac_if", mac_if_0);
       end

       mon = mac_monitor::type_id::create ("mon",this);
       uvm_config_db#(virtual mac_if)::set(this, "mon", "mac_if", mac_if_0);

 endfunction: build_phase

 function void mac_agent::connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      if (is_active == UVM_ACTIVE) 
        drv.seq_item_port.connect(seqr.seq_item_export);
      
      this.analysis_port = mon.analysis_port;

 endfunction
