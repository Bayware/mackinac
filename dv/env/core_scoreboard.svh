`ifndef CORE_SCOREBOARD_SVH
`define CORE_SCOREBOARD_SVH

class core_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(core_scoreboard)

  sci_type rci2sci[ rci_type ];
  port_id_type sci2port[ sci_type ];

  core_port_queue port_q;

  `uvm_analysis_imp_decl(_in_port0)
  `uvm_analysis_imp_decl(_in_port1)
  `uvm_analysis_imp_decl(_in_port2)
  `uvm_analysis_imp_decl(_in_port3)
  `uvm_analysis_imp_decl(_in_port4)
  `uvm_analysis_imp_decl(_in_port5)

  `uvm_analysis_imp_decl(_out_port0)
  `uvm_analysis_imp_decl(_out_port1)
  `uvm_analysis_imp_decl(_out_port2)
  `uvm_analysis_imp_decl(_out_port3)
  `uvm_analysis_imp_decl(_out_port4)
  `uvm_analysis_imp_decl(_out_port5)

  uvm_analysis_imp_in_port0 #(special_packet, core_scoreboard) in_port0;
  uvm_analysis_imp_in_port1 #(special_packet, core_scoreboard) in_port1;
  uvm_analysis_imp_in_port2 #(special_packet, core_scoreboard) in_port2;
  uvm_analysis_imp_in_port3 #(special_packet, core_scoreboard) in_port3;
  uvm_analysis_imp_in_port4 #(special_packet, core_scoreboard) in_port4;
  uvm_analysis_imp_in_port5 #(special_packet, core_scoreboard) in_port5;

  uvm_analysis_imp_out_port0 #(special_packet, core_scoreboard) out_port0;
  uvm_analysis_imp_out_port1 #(special_packet, core_scoreboard) out_port1;
  uvm_analysis_imp_out_port2 #(special_packet, core_scoreboard) out_port2;
  uvm_analysis_imp_out_port3 #(special_packet, core_scoreboard) out_port3;
  uvm_analysis_imp_out_port4 #(special_packet, core_scoreboard) out_port4;
  uvm_analysis_imp_out_port5 #(special_packet, core_scoreboard) out_port5;

  uvm_tlm_fifo #(special_packet) out_fifo00;
  uvm_tlm_fifo #(special_packet) out_fifo01;
  uvm_tlm_fifo #(special_packet) out_fifo02;
  uvm_tlm_fifo #(special_packet) out_fifo03;
  uvm_tlm_fifo #(special_packet) out_fifo04;
  uvm_tlm_fifo #(special_packet) out_fifo05;

  uvm_tlm_fifo #(special_packet) out_fifo10;
  uvm_tlm_fifo #(special_packet) out_fifo11;
  uvm_tlm_fifo #(special_packet) out_fifo12;
  uvm_tlm_fifo #(special_packet) out_fifo13;
  uvm_tlm_fifo #(special_packet) out_fifo14;
  uvm_tlm_fifo #(special_packet) out_fifo15;

  uvm_tlm_fifo #(special_packet) out_fifo20;
  uvm_tlm_fifo #(special_packet) out_fifo21;
  uvm_tlm_fifo #(special_packet) out_fifo22;
  uvm_tlm_fifo #(special_packet) out_fifo23;
  uvm_tlm_fifo #(special_packet) out_fifo24;
  uvm_tlm_fifo #(special_packet) out_fifo25;

  uvm_tlm_fifo #(special_packet) out_fifo30;
  uvm_tlm_fifo #(special_packet) out_fifo31;
  uvm_tlm_fifo #(special_packet) out_fifo32;
  uvm_tlm_fifo #(special_packet) out_fifo33;
  uvm_tlm_fifo #(special_packet) out_fifo34;
  uvm_tlm_fifo #(special_packet) out_fifo35;

  uvm_tlm_fifo #(special_packet) out_fifo40;
  uvm_tlm_fifo #(special_packet) out_fifo41;
  uvm_tlm_fifo #(special_packet) out_fifo42;
  uvm_tlm_fifo #(special_packet) out_fifo43;
  uvm_tlm_fifo #(special_packet) out_fifo44;
  uvm_tlm_fifo #(special_packet) out_fifo45;

  uvm_tlm_fifo #(special_packet) out_fifo50;
  uvm_tlm_fifo #(special_packet) out_fifo51;
  uvm_tlm_fifo #(special_packet) out_fifo52;
  uvm_tlm_fifo #(special_packet) out_fifo53;
  uvm_tlm_fifo #(special_packet) out_fifo54;
  uvm_tlm_fifo #(special_packet) out_fifo55;

  function new(string name, uvm_component parent);
	super.new(name, parent);

	in_port0 = new("in_port0", this);
	in_port1 = new("in_port1", this);
	in_port2 = new("in_port2", this);
	in_port3 = new("in_port3", this);
	in_port4 = new("in_port4", this);
	in_port5 = new("in_port5", this);

	out_port0 = new("out_port0", this);
	out_port1 = new("out_port1", this);
	out_port2 = new("out_port2", this);
	out_port3 = new("out_port3", this);
	out_port4 = new("out_port4", this);
	out_port5 = new("out_port5", this);

        out_fifo00 = new("out_fifo00", this, 200);
        out_fifo01 = new("out_fifo01", this, 200);
        out_fifo02 = new("out_fifo02", this, 200);
        out_fifo03 = new("out_fifo03", this, 200);
        out_fifo04 = new("out_fifo04", this, 200);
        out_fifo05 = new("out_fifo05", this, 200);

        out_fifo10 = new("out_fifo10", this, 200);
        out_fifo11 = new("out_fifo11", this, 200);
        out_fifo12 = new("out_fifo12", this, 200);
        out_fifo13 = new("out_fifo13", this, 200);
        out_fifo14 = new("out_fifo14", this, 200);
        out_fifo15 = new("out_fifo15", this, 200);

        out_fifo20 = new("out_fifo20", this, 200);
        out_fifo21 = new("out_fifo21", this, 200);
        out_fifo22 = new("out_fifo22", this, 200);
        out_fifo23 = new("out_fifo23", this, 200);
        out_fifo24 = new("out_fifo24", this, 200);
        out_fifo25 = new("out_fifo25", this, 200);

        out_fifo30 = new("out_fifo30", this, 200);
        out_fifo31 = new("out_fifo31", this, 200);
        out_fifo32 = new("out_fifo32", this, 200);
        out_fifo33 = new("out_fifo33", this, 200);
        out_fifo34 = new("out_fifo34", this, 200);
        out_fifo35 = new("out_fifo35", this, 200);

        out_fifo40 = new("out_fifo40", this, 200);
        out_fifo41 = new("out_fifo41", this, 200);
        out_fifo42 = new("out_fifo42", this, 200);
        out_fifo43 = new("out_fifo43", this, 200);
        out_fifo44 = new("out_fifo44", this, 200);
        out_fifo45 = new("out_fifo45", this, 200);

        out_fifo50 = new("out_fifo50", this, 200);
        out_fifo51 = new("out_fifo51", this, 200);
        out_fifo52 = new("out_fifo52", this, 200);
        out_fifo53 = new("out_fifo53", this, 200);
        out_fifo54 = new("out_fifo54", this, 200);
        out_fifo55 = new("out_fifo55", this, 200);

  endfunction

  extern virtual function void write_in_port0(special_packet trans);
  extern virtual function void write_in_port1(special_packet trans);
  extern virtual function void write_in_port2(special_packet trans);
  extern virtual function void write_in_port3(special_packet trans);
  extern virtual function void write_in_port4(special_packet trans);
  extern virtual function void write_in_port5(special_packet trans);

  extern virtual function void write_out_port0(special_packet trans);
  extern virtual function void write_out_port1(special_packet trans);
  extern virtual function void write_out_port2(special_packet trans);
  extern virtual function void write_out_port3(special_packet trans);
  extern virtual function void write_out_port4(special_packet trans);
  extern virtual function void write_out_port5(special_packet trans);

  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void check_phase(uvm_phase phase);
  extern virtual function void enq_dst(port_id_type dst_port, special_packet trans);

endclass

function void core_scoreboard::connect_phase(uvm_phase phase);
   super.connect_phase(phase);

   if(!uvm_config_db#(core_port_queue)::get(this, "", "core_port_queue", port_q)) 
      `uvm_fatal("CORE_SCOREBOARD", "port_q not found");

endfunction

function void core_scoreboard::enq_dst(port_id_type dst_port, special_packet trans);

  special_packet s_pkt;
  s_pkt = new("special_packet");
  s_pkt.copy(trans);

 `uvm_info("CORE_SCOREBOARD", $sformatf("enqueue packet %0d into out_fifo (%0d %0d)", s_pkt.s_packet_num, s_pkt.s_src_port, dst_port), UVM_HIGH);

  s_pkt.print_packet();

  case (trans.s_src_port)
	  0: begin
		case (dst_port)
  			0: out_fifo00.try_put(s_pkt);
  			1: out_fifo01.try_put(s_pkt);
  			2: out_fifo02.try_put(s_pkt);
  			3: out_fifo03.try_put(s_pkt);
  			4: out_fifo04.try_put(s_pkt);
  			5: out_fifo05.try_put(s_pkt);
		endcase
	  end
	  1: begin
		case (dst_port)
  			0: out_fifo10.try_put(s_pkt);
  			1: out_fifo11.try_put(s_pkt);
  			2: out_fifo12.try_put(s_pkt);
  			3: out_fifo13.try_put(s_pkt);
  			4: out_fifo14.try_put(s_pkt);
  			5: out_fifo15.try_put(s_pkt);
		endcase
	  end
	  2: begin
		case (dst_port)
  			0: out_fifo20.try_put(s_pkt);
  			1: out_fifo21.try_put(s_pkt);
  			2: out_fifo22.try_put(s_pkt);
  			3: out_fifo23.try_put(s_pkt);
  			4: out_fifo24.try_put(s_pkt);
  			5: out_fifo25.try_put(s_pkt);
		endcase
	  end
	  3: begin
		case (dst_port)
  			0: out_fifo30.try_put(s_pkt);
  			1: out_fifo31.try_put(s_pkt);
  			2: out_fifo32.try_put(s_pkt);
  			3: out_fifo33.try_put(s_pkt);
  			4: out_fifo34.try_put(s_pkt);
  			5: out_fifo35.try_put(s_pkt);
		endcase
	  end
	  4: begin
		case (dst_port)
  			0: out_fifo40.try_put(s_pkt);
  			1: out_fifo41.try_put(s_pkt);
  			2: out_fifo42.try_put(s_pkt);
  			3: out_fifo43.try_put(s_pkt);
  			4: out_fifo44.try_put(s_pkt);
  			5: out_fifo45.try_put(s_pkt);
		endcase
	  end
	  5: begin
		case (dst_port)
  			0: out_fifo50.try_put(s_pkt);
  			1: out_fifo51.try_put(s_pkt);
  			2: out_fifo52.try_put(s_pkt);
  			3: out_fifo53.try_put(s_pkt);
  			4: out_fifo54.try_put(s_pkt);
  			5: out_fifo55.try_put(s_pkt);
		endcase
	  end
  endcase

endfunction

function void core_scoreboard::check_phase(uvm_phase phase);
  special_packet exp_pkt;
  if(out_fifo00.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src0-to-dst0 fifo"));
  if(out_fifo01.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src0-to-dst1 fifo"));
  if(out_fifo02.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src0-to-dst2 fifo"));
  if(out_fifo03.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src0-to-dst3 fifo"));
  if(out_fifo04.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src0-to-dst4 fifo"));
  if(out_fifo05.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src0-to-dst5 fifo"));
  if(out_fifo10.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src1-to-dst0 fifo"));
  if(out_fifo11.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src1-to-dst1 fifo"));
  if(out_fifo12.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src1-to-dst2 fifo"));
  if(out_fifo13.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src1-to-dst3 fifo"));
  if(out_fifo14.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src1-to-dst4 fifo"));
  if(out_fifo15.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src1-to-dst5 fifo"));
  if(out_fifo20.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src2-to-dst0 fifo"));
  if(out_fifo21.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src2-to-dst1 fifo"));
  if(out_fifo22.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src2-to-dst2 fifo"));
  if(out_fifo23.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src2-to-dst3 fifo"));
  if(out_fifo24.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src2-to-dst4 fifo"));
  if(out_fifo25.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src2-to-dst5 fifo"));
  if(out_fifo30.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src3-to-dst0 fifo"));
  if(out_fifo31.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src3-to-dst1 fifo"));
  if(out_fifo32.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src3-to-dst2 fifo"));
  if(out_fifo33.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src3-to-dst3 fifo"));
  if(out_fifo34.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src3-to-dst4 fifo"));
  if(out_fifo35.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src3-to-dst5 fifo"));
  if(out_fifo40.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src4-to-dst0 fifo"));
  if(out_fifo41.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src4-to-dst1 fifo"));
  if(out_fifo42.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src4-to-dst2 fifo"));
  if(out_fifo43.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src4-to-dst3 fifo"));
  if(out_fifo44.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src4-to-dst4 fifo"));
  if(out_fifo45.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src4-to-dst5 fifo"));
  if(out_fifo50.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src5-to-dst0 fifo"));
  if(out_fifo51.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src5-to-dst1 fifo"));
  if(out_fifo52.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src5-to-dst2 fifo"));
  if(out_fifo53.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src5-to-dst3 fifo"));
  if(out_fifo54.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src5-to-dst4 fifo"));
  if(out_fifo55.try_get(exp_pkt)!=0) 
   `uvm_error("CORE_SCOREBOARD", $sformatf("more expected packet(s) in src5-to-dst5 fifo"));
endfunction

function void core_scoreboard::write_in_port0(special_packet trans);
  special_packet trans1;

  trans1 = port_q.port_queue[0].pop_front();
  if(trans1 == null) `uvm_error("CORE_SCOREBOARD", "src_port 0 queue has no packet")
  else

  for (int i = 0; i<trans1.dst_rci_array.size(); i++) 
	  if(trans1.dst_rci_array.size()!=0)
     enq_dst(sci2port[rci2sci[trans1.dst_rci_array[i]]], trans1);

//  trans1.print();

endfunction

function void core_scoreboard::write_in_port1(special_packet trans);
  special_packet trans1;

  trans1 = port_q.port_queue[1].pop_front();
  if(trans1 == null) `uvm_error("CORE_SCOREBOARD", "src_port 1 queue has no packet");
  
  for (int i = 0; i<trans1.dst_rci_array.size(); i++) 
	  if(trans1.dst_rci_array.size()!=0)
     enq_dst(sci2port[rci2sci[trans1.dst_rci_array[i]]], trans1);

//    trans1.print();

endfunction

function void core_scoreboard::write_in_port2(special_packet trans);
  special_packet trans1;

  trans1 = port_q.port_queue[2].pop_front();
  if(trans1 == null) `uvm_error("CORE_SCOREBOARD", "src_port 2 queue has no packet");
  
  for (int i = 0; i<trans1.dst_rci_array.size(); i++) 
	  if(trans1.dst_rci_array.size()!=0)
     enq_dst(sci2port[rci2sci[trans1.dst_rci_array[i]]], trans1);

//     trans1.print();

endfunction

function void core_scoreboard::write_in_port3(special_packet trans);
  special_packet trans1;

  trans1 = port_q.port_queue[3].pop_front();
  if(trans1 == null) `uvm_error("CORE_SCOREBOARD", "src_port 3 queue has no packet");
  
  for (int i = 0; i<trans1.dst_rci_array.size(); i++) 
	  if(trans1.dst_rci_array.size()!=0)
     enq_dst(sci2port[rci2sci[trans1.dst_rci_array[i]]], trans1);

//     trans1.print();

endfunction

function void core_scoreboard::write_in_port4(special_packet trans);
  special_packet trans1;

  trans1 = port_q.port_queue[4].pop_front();
  if(trans1 == null) `uvm_error("CORE_SCOREBOARD", "src_port 4 queue has no packet");
  
  for (int i = 0; i<trans1.dst_rci_array.size(); i++) 
	  if(trans1.dst_rci_array.size()!=0)
     enq_dst(sci2port[rci2sci[trans1.dst_rci_array[i]]], trans1);

//     trans1.print();

endfunction

function void core_scoreboard::write_in_port5(special_packet trans);
  special_packet trans1;

  trans1 = port_q.port_queue[5].pop_front();
  if(trans1 == null) `uvm_error("CORE_SCOREBOARD", "src_port 5 queue has no packet");
  
  for (int i = 0; i<trans1.dst_rci_array.size(); i++) 
	  if(trans1.dst_rci_array.size()!=0)
     enq_dst(sci2port[rci2sci[trans1.dst_rci_array[i]]], trans1);

//     trans1.print();

endfunction

function void core_scoreboard::write_out_port0(special_packet trans);
  special_packet exp;
  int c;
   
 `uvm_info("CORE_SCOREBOARD", $sformatf("dequeue packet %0d from out_fifo (%0d 0)", trans.s_packet_num, trans.s_src_port), UVM_HIGH);

  case (trans.s_src_port)
	  0: begin
   		if(out_fifo00.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 0 from src_port 0")
		else
   		
   			c = trans.compare(exp);
	  end
	  1: begin
   		if(out_fifo10.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 0 from src_port 1")
		else
   		
   			c = trans.compare(exp);
	  end
	  2: begin
   		if(out_fifo20.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 0 from src_port 2")
		else
   		
   			c = trans.compare(exp);
	  end
	  3: begin
   		if(out_fifo30.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 0 from src_port 3")
		else
   		
   			c = trans.compare(exp);
	  end
	  4: begin
   		if(out_fifo40.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 0 from src_port 4")
		else
   		
   			c = trans.compare(exp);
	  end
	  5: begin
   		if(out_fifo50.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 0 from src_port 5")
		else
   		
   			c = trans.compare(exp);
	  end
  endcase

endfunction

function void core_scoreboard::write_out_port1(special_packet trans);
  special_packet exp;
  int c;
   
 `uvm_info("CORE_SCOREBOARD", $sformatf("dequeue packet %0d from out_fifo (%0d 1)", trans.s_packet_num, trans.s_src_port), UVM_HIGH);

  case (trans.s_src_port)
	  0: begin
   		if(out_fifo01.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 1 from src_port 0")
		else
   		
   			c = trans.compare(exp);
	  end
	  1: begin
   		if(out_fifo11.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 1 from src_port 1")
		else
   		
   			c = trans.compare(exp);
	  end
	  2: begin
   		if(out_fifo21.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 1 from src_port 2")
		
		else begin
			exp.print_packet();
   			c = trans.compare(exp);
		end
	  end
	  3: begin
   		if(out_fifo31.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 1 from src_port 3")
		else begin
   		
			exp.print_packet();
   			c = trans.compare(exp);
		end
	  end
	  4: begin
   		if(out_fifo41.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 1 from src_port 4")
		else
   		
   			c = trans.compare(exp);
	  end
	  5: begin
   		if(out_fifo51.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 1 from src_port 5")
		else
   		
   			c = trans.compare(exp);
	  end
  endcase

endfunction

function void core_scoreboard::write_out_port2(special_packet trans);
  special_packet exp;
  int c;
   
 `uvm_info("CORE_SCOREBOARD", $sformatf("dequeue packet %0d from out_fifo (%0d 2)", trans.s_packet_num, trans.s_src_port), UVM_HIGH);

  case (trans.s_src_port)
	  0: begin
   		if(out_fifo02.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 2 from src_port 0")
		else
   		
   			c = trans.compare(exp);
	  end
	  1: begin
   		if(out_fifo12.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 2 from src_port 1")
		else
   		
   			c = trans.compare(exp);
	  end
	  2: begin
   		if(out_fifo22.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 2 from src_port 2")
		else
   		
   			c = trans.compare(exp);
	  end
	  3: begin
   		if(out_fifo32.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 2 from src_port 3")
		else
   		
   			c = trans.compare(exp);
	  end
	  4: begin
   		if(out_fifo42.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 2 from src_port 4")
		else
   		
   			c = trans.compare(exp);
	  end
	  5: begin
   		if(out_fifo52.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 2 from src_port 5")
		else
   		
   			c = trans.compare(exp);
	  end
  endcase

endfunction

function void core_scoreboard::write_out_port3(special_packet trans);
  special_packet exp;
  int c;
   
 `uvm_info("CORE_SCOREBOARD", $sformatf("dequeue packet %0d from out_fifo (%0d 3)", trans.s_packet_num, trans.s_src_port), UVM_HIGH);

  case (trans.s_src_port)
	  0: begin
   		if(out_fifo03.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 3 from src_port 0")
		else
   		
   			c = trans.compare(exp);
	  end
	  1: begin
   		if(out_fifo13.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 3 from src_port 1")
		else
   		
   			c = trans.compare(exp);
	  end
	  2: begin
   		if(out_fifo23.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 3 from src_port 2")
		else
   		
   			c = trans.compare(exp);
	  end
	  3: begin
   		if(out_fifo33.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 3 from src_port 3")
		else
   		
   			c = trans.compare(exp);
	  end
	  4: begin
   		if(out_fifo43.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 3 from src_port 4")
		else
   		
   			c = trans.compare(exp);
	  end
	  5: begin
   		if(out_fifo53.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 3 from src_port 5")
		else
   		
   			c = trans.compare(exp);
	  end
  endcase

endfunction

function void core_scoreboard::write_out_port4(special_packet trans);
  special_packet exp;
  int c;
   
 `uvm_info("CORE_SCOREBOARD", $sformatf("dequeue packet %0d from out_fifo (%0d 4)", trans.s_packet_num, trans.s_src_port), UVM_HIGH);

  case (trans.s_src_port)
	  0: begin
   		if(out_fifo04.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 4 from src_port 0")
		else
   		
   			c = trans.compare(exp);
	  end
	  1: begin
   		if(out_fifo14.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 4 from src_port 1")
		else
   		
   			c = trans.compare(exp);
	  end
	  2: begin
   		if(out_fifo24.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 4 from src_port 2")
		else
   		
   			c = trans.compare(exp);
	  end
	  3: begin
   		if(out_fifo34.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 4 from src_port 3")
		else
   		
   			c = trans.compare(exp);
	  end
	  4: begin
   		if(out_fifo44.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 4 from src_port 4")
		else
   		
   			c = trans.compare(exp);
	  end
	  5: begin
   		if(out_fifo54.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 4 from src_port 5")
		else
   		
   			c = trans.compare(exp);
	  end
  endcase

endfunction

function void core_scoreboard::write_out_port5(special_packet trans);
  special_packet exp;
  int c;
   
 `uvm_info("CORE_SCOREBOARD", $sformatf("dequeue packet %0d from out_fifo (%0d 5)", trans.s_packet_num, trans.s_src_port), UVM_HIGH);

  case (trans.s_src_port)
	  0: begin
   		if(out_fifo05.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 5 from src_port 0")
		else
   		
   			c = trans.compare(exp);
	  end
	  1: begin
   		if(out_fifo15.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 5 from src_port 1")
		else
   		
   			c = trans.compare(exp);
	  end
	  2: begin
   		if(out_fifo25.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 5 from src_port 2")
		else
   		
   			c = trans.compare(exp);
	  end
	  3: begin
   		if(out_fifo35.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 5 from src_port 3")
		else
   		
   			c = trans.compare(exp);
	  end
	  4: begin
   		if(out_fifo45.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 5 from src_port 4")
		else
   		
   			c = trans.compare(exp);
	  end
	  5: begin
   		if(out_fifo55.try_get(exp) == 0) 
			`uvm_error("CORE_SCOREBOARD", "Should not receive a packet on dst_port 5 from src_port 5")
		else
   		
   			c = trans.compare(exp);
	  end
  endcase

endfunction

`endif
