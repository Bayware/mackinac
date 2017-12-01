`ifndef CORE_ENV_SVH
`define CORE_ENV_SVH

typedef uvm_reg_predictor#( pio_wr_transaction ) encap_reg_predictor;

class core_env extends uvm_env;
  mac_agent  mac0_rx_agt;
  mac_config mac0_rx_cfg;
  mac_agent  mac1_rx_agt;
  mac_config mac1_rx_cfg;
  dma_agent  dma0_rx_agt;
  dma_config dma0_rx_cfg;
  dma_agent  dma1_rx_agt;
  dma_config dma1_rx_cfg;
  dma_agent  dma2_rx_agt;
  dma_config dma2_rx_cfg;
  dma_agent  dma3_rx_agt;
  dma_config dma3_rx_cfg;

  mac_agent  mac0_tx_agt;
  mac_config mac0_tx_cfg;
  mac_agent  mac1_tx_agt;
  mac_config mac1_tx_cfg;
  dma_agent  dma0_tx_agt;
  dma_config dma0_tx_cfg;
  dma_agent  dma1_tx_agt;
  dma_config dma1_tx_cfg;
  dma_agent  dma2_tx_agt;
  dma_config dma2_tx_cfg;
  dma_agent  dma3_tx_agt;
  dma_config dma3_tx_cfg;

  pio_wr_agent  core_pio_wr_agt;
  pio_wr_config  core_pio_wr_cfg;
  pio_rd_agent  core_pio_rd_agt;
  pio_rd_config  core_pio_rd_cfg;

  core_config core_cfg;
  core_scoreboard sb;
  core_port_queue port_q;
  encap_reg_block encap_reg;
  encap_mem_block encap_mem;
  encap_reg_predictor encap_predictor;
  decap_mem_block decap_mem;
  irl_mem_block irl_mem;
  class_mem_block class_mem;
  asa_mem_block asa_mem;
  tm_mem_block tm_mem;

  `uvm_component_utils (core_env)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  extern virtual function void build_phase (uvm_phase phase);
  extern virtual function void connect_phase (uvm_phase phase);
  extern virtual task reset_phase (uvm_phase phase);
  extern virtual task configure_phase (uvm_phase phase);
  extern virtual task main_phase (uvm_phase phase);

endclass

function void core_env::build_phase (uvm_phase phase);

  super.build_phase(phase);
  uvm_config_db#(core_env)::set(this, "*", "core_env", this);

  mac0_rx_agt = mac_agent::type_id::create("mac0_rx_agt", this);
  mac0_rx_cfg = mac_config::type_id::create("mac0_rx_cfg", this);
  mac0_rx_cfg.mac_num = 0;
  mac0_rx_cfg.randomize();
  uvm_config_db#(mac_config)::set(this, "mac0_rx_agt.*", "mac_config", mac0_rx_cfg);

  mac1_rx_agt = mac_agent::type_id::create("mac1_rx_agt", this);
  mac1_rx_cfg = mac_config::type_id::create("mac1_rx_cfg", this);
  mac1_rx_cfg.mac_num = 1;
  mac1_rx_cfg.randomize();
  uvm_config_db#(mac_config)::set(this, "mac1_rx_agt.*", "mac_config", mac1_rx_cfg);

  dma0_rx_agt = dma_agent::type_id::create("dma0_rx_agt", this);
  dma0_rx_cfg = dma_config::type_id::create("dma0_rx_cfg", this);
  dma0_rx_cfg.dma_num = 0;
  dma0_rx_cfg.randomize();
  uvm_config_db#(dma_config)::set(this, "dma0_rx_agt.*", "dma_config", dma0_rx_cfg);

  dma1_rx_agt = dma_agent::type_id::create("dma1_rx_agt", this);
  dma1_rx_cfg = dma_config::type_id::create("dma1_rx_cfg", this);
  dma1_rx_cfg.dma_num = 1;
  dma1_rx_cfg.randomize();
  uvm_config_db#(dma_config)::set(this, "dma1_rx_agt.*", "dma_config", dma1_rx_cfg);

  dma2_rx_agt = dma_agent::type_id::create("dma2_rx_agt", this);
  dma2_rx_cfg = dma_config::type_id::create("dma2_rx_cfg", this);
  dma2_rx_cfg.dma_num = 2;
  dma2_rx_cfg.randomize();
  uvm_config_db#(dma_config)::set(this, "dma2_rx_agt.*", "dma_config", dma2_rx_cfg);

  dma3_rx_agt = dma_agent::type_id::create("dma3_rx_agt", this);
  dma3_rx_cfg = dma_config::type_id::create("dma3_rx_cfg", this);
  dma3_rx_cfg.dma_num = 3;
  dma3_rx_cfg.randomize();
  uvm_config_db#(dma_config)::set(this, "dma3_rx_agt.*", "dma_config", dma3_rx_cfg);

  mac0_tx_agt = mac_agent::type_id::create("mac0_tx_agt", this);
  mac0_tx_agt.is_active = UVM_PASSIVE;
  mac0_tx_cfg = mac_config::type_id::create("mac0_tx_cfg", this);
  mac0_tx_cfg.mac_num = 0;
  uvm_config_db#(mac_config)::set(this, "mac0_tx_agt.*", "mac_config", mac0_tx_cfg);

  mac1_tx_agt = mac_agent::type_id::create("mac1_tx_agt", this);
  mac1_tx_agt.is_active = UVM_PASSIVE;
  mac1_tx_cfg = mac_config::type_id::create("mac1_tx_cfg", this);
  mac1_tx_cfg.mac_num = 1;
  uvm_config_db#(mac_config)::set(this, "mac1_tx_agt.*", "mac_config", mac1_tx_cfg);

  dma0_tx_agt = dma_agent::type_id::create("dma0_tx_agt", this);
  dma0_tx_agt.is_active = UVM_PASSIVE;
  dma0_tx_cfg = dma_config::type_id::create("dma0_tx_cfg", this);
  dma0_tx_cfg.dma_num = 0;
  uvm_config_db#(dma_config)::set(this, "dma0_tx_agt.*", "dma_config", dma0_tx_cfg);

  dma1_tx_agt = dma_agent::type_id::create("dma1_tx_agt", this);
  dma1_tx_agt.is_active = UVM_PASSIVE;
  dma1_tx_cfg = dma_config::type_id::create("dma1_tx_cfg", this);
  dma1_tx_cfg.dma_num = 1;
  uvm_config_db#(dma_config)::set(this, "dma1_tx_agt.*", "dma_config", dma1_tx_cfg);

  dma2_tx_agt = dma_agent::type_id::create("dma2_tx_agt", this);
  dma2_tx_agt.is_active = UVM_PASSIVE;
  dma2_tx_cfg = dma_config::type_id::create("dma2_tx_cfg", this);
  dma2_tx_cfg.dma_num = 2;
  uvm_config_db#(dma_config)::set(this, "dma2_tx_agt.*", "dma_config", dma2_tx_cfg);

  dma3_tx_agt = dma_agent::type_id::create("dma3_tx_agt", this);
  dma3_tx_agt.is_active = UVM_PASSIVE;
  dma3_tx_cfg = dma_config::type_id::create("dma3_tx_cfg", this);
  dma3_tx_cfg.dma_num = 3;
  uvm_config_db#(dma_config)::set(this, "dma3_tx_agt.*", "dma_config", dma3_tx_cfg);

  core_pio_wr_agt = pio_wr_agent::type_id::create("core_pio_wr_agt", this);
  core_pio_wr_cfg = pio_wr_config::type_id::create("core_pio_wr_cfg", this);
  uvm_config_db#(pio_wr_config)::set(this, "core_pio_wr_agt.*", "pio_wr_config", core_pio_wr_cfg);

  core_pio_rd_agt = pio_rd_agent::type_id::create("core_pio_rd_agt", this);
  core_pio_rd_cfg = pio_rd_config::type_id::create("core_pio_rd_cfg", this);
  uvm_config_db#(pio_rd_config)::set(this, "core_pio_rd_agt.*", "pio_rd_config", core_pio_rd_cfg);

  sb = core_scoreboard::type_id::create("sb", this);

  port_q = new(); 
  uvm_config_db#(core_port_queue)::set(this, "*", "core_port_queue", port_q);

  encap_reg = encap_reg_block::type_id::create("encap_reg", this);
  encap_reg.build();
  uvm_config_db#(encap_reg_block)::set(this, "*", "encap_reg_block", encap_reg);

  encap_mem = encap_mem_block::type_id::create("encap_mem", this);
  encap_mem.build();
  uvm_config_db#(encap_mem_block)::set(this, "*", "encap_mem_block", encap_mem);

  encap_predictor = encap_reg_predictor::type_id::create("encap_predictor", this);

  decap_mem = decap_mem_block::type_id::create("decap_mem", this);
  decap_mem.build();
  uvm_config_db#(decap_mem_block)::set(this, "*", "decap_mem_block", decap_mem);

  irl_mem = irl_mem_block::type_id::create("irl_mem", this);
  irl_mem.build();
  uvm_config_db#(irl_mem_block)::set(this, "*", "irl_mem_block", irl_mem);

  class_mem = class_mem_block::type_id::create("class_mem", this);
  class_mem.build();
  uvm_config_db#(class_mem_block)::set(this, "*", "class_mem_block", class_mem);

  asa_mem = asa_mem_block::type_id::create("asa_mem", this);
  asa_mem.build();
  uvm_config_db#(asa_mem_block)::set(this, "*", "asa_mem_block", asa_mem);

  tm_mem = tm_mem_block::type_id::create("tm_mem", this);
  tm_mem.build();
  uvm_config_db#(tm_mem_block)::set(this, "*", "tm_mem_block", tm_mem);

  core_cfg = core_config::type_id::create("core_cfg", this);
  uvm_config_db#(core_config)::set(this, "*", "core_config", core_cfg);

endfunction

function void core_env::connect_phase(uvm_phase phase);

  super.connect_phase(phase);

  mac0_rx_agt.analysis_port.connect(sb.in_port0);
  mac1_rx_agt.analysis_port.connect(sb.in_port1);
  dma0_rx_agt.analysis_port.connect(sb.in_port2);
  dma1_rx_agt.analysis_port.connect(sb.in_port3);
  dma2_rx_agt.analysis_port.connect(sb.in_port4);
  dma3_rx_agt.analysis_port.connect(sb.in_port5);

  mac0_tx_agt.analysis_port.connect(sb.out_port0);
  mac1_tx_agt.analysis_port.connect(sb.out_port1);
  dma0_tx_agt.analysis_port.connect(sb.out_port2);
  dma1_tx_agt.analysis_port.connect(sb.out_port3);
  dma2_tx_agt.analysis_port.connect(sb.out_port4);
  dma3_tx_agt.analysis_port.connect(sb.out_port5);

  encap_reg.reg_map.set_sequencer( .sequencer( core_pio_wr_agt.seqr ), .adapter( core_pio_wr_agt.adapter ) );
  encap_mem.reg_map.set_sequencer( .sequencer( core_pio_wr_agt.seqr ), .adapter( core_pio_wr_agt.adapter ) );
  decap_mem.reg_map.set_sequencer( .sequencer( core_pio_wr_agt.seqr ), .adapter( core_pio_wr_agt.adapter ) );
  irl_mem.reg_map.set_sequencer( .sequencer( core_pio_wr_agt.seqr ), .adapter( core_pio_wr_agt.adapter ) );
  class_mem.reg_map.set_sequencer( .sequencer( core_pio_wr_agt.seqr ), .adapter( core_pio_wr_agt.adapter ) );
  asa_mem.reg_map.set_sequencer( .sequencer( core_pio_wr_agt.seqr ), .adapter( core_pio_wr_agt.adapter ) );
  tm_mem.reg_map.set_sequencer( .sequencer( core_pio_wr_agt.seqr ), .adapter( core_pio_wr_agt.adapter ) );

  encap_reg.reg_map.set_auto_predict( .on( 0 ) );
  encap_predictor.map     = encap_reg.reg_map;
  encap_predictor.adapter = core_pio_wr_agt.adapter;
  core_pio_wr_agt.analysis_port.connect( encap_predictor.bus_in );

endfunction

task core_env::reset_phase(uvm_phase phase);

  super.reset_phase(phase);
  phase.raise_objection(this);
  #200ns;
  phase.drop_objection(this);

endtask

task core_env::configure_phase(uvm_phase phase);

  bit [31:0] timeout = core_cfg.timeout;
  super.configure_phase(phase);

  fork
    begin
	#timeout;
	`uvm_fatal("CORE_ENV", "simulation hangs");
    end
    begin
	forever begin
	  #1000000;
	  `uvm_info("CORE_ENV", "simulation running", UVM_NONE);
	end
    end
  join_none

endtask

task core_env::main_phase(uvm_phase phase);

  bit [31:0] timeout = core_cfg.timeout ;

  super.main_phase(phase);

  fork
    begin
	#timeout 
	`uvm_fatal("CORE_ENV", "simulation hangs");
    end
    begin
	forever begin
	  #1000000;
	  `uvm_info("CORE_ENV", "simulation running", UVM_NONE);
	end
    end
  join_none

endtask

`endif
