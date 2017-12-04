
class dma_monitor extends uvm_monitor;

  virtual dma_if dma_if_0;
  dma_config dma_config_0;

  logic [7:0] pkt_data[];

  uvm_analysis_port #(special_packet) analysis_port;

  `uvm_component_utils(dma_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task probe_pins(special_packet s_pkt);

endclass

  function void dma_monitor::build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual dma_if)::get(this, "", "dma_if", dma_if_0)) 
      `uvm_fatal("DMA_MONITOR", "dma_if not found");

    if (!(uvm_config_db#(dma_config)::get(this, "", "dma_config", dma_config_0)))
       `uvm_fatal("DMA_MONITOR", "dma_config not found")

    analysis_port = new("analysis_port", this);

  endfunction

  task dma_monitor::run_phase(uvm_phase phase);

    special_packet s_pkt;

    forever begin

      s_pkt = new("special_packet"); 
     
      probe_pins(s_pkt);
//      `uvm_info("DMA_MONITOR", s_pkt.sprint(), UVM_MEDIUM);

      analysis_port.write(s_pkt);

    end

  endtask

  task dma_monitor::probe_pins(special_packet s_pkt);

    bit [63:0] data;
    logic eop;
    int pkt_size, last_byte_loc;
    int i, j;

    eop = 0;
    pkt_data.delete();

    while (dma_if_0.mon_cb.valid !== 1'b1) @(dma_if_0.mon_cb);

    while (eop != 1) begin

      data = dma_if_0.mon_cb.data;
   
      pkt_data = new[pkt_data.size()+8] (pkt_data);
      pkt_size = pkt_data.size();

      for (i=0; i<8; i++) 
        for (j=0; j<8; j++) 
          pkt_data[pkt_size-8+i][j] = data[64-8-i*8+j];
        
      if (dma_if_0.mon_cb.last == 1) begin
        eop = 1;
      end else begin
        @(dma_if_0.mon_cb);
        while ( dma_if_0.mon_cb.valid !== 1'b1) @(dma_if_0.mon_cb);
      end

    end

    while (pkt_data[pkt_size-3]!=8'ha5&&pkt_data[pkt_size-4]!=8'h5a) begin
	pkt_size = pkt_size-1;
	if (pkt_size==34) 
      		`uvm_fatal("DMA_MONITOR", "last byte of the packet not found")
    end

    s_pkt.packet_data = new[pkt_size];

    foreach (pkt_data[i]) 
      s_pkt.packet_data[i] = pkt_data[i];

    s_pkt.s_src_port = pkt_data[pkt_size-1];
    s_pkt.s_packet_num = pkt_data[pkt_size-2];

    repeat (1)  @(dma_if_0.mon_cb);

  endtask
