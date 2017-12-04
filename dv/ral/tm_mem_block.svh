class tm_mem_block extends uvm_reg_block;
   `uvm_object_utils( tm_mem_block )
 
   rand uvm_mem tm_queue_association;

   rand uvm_mem tm_queue_profile0;
   rand uvm_mem tm_wdrr_quantum0;
   rand uvm_mem tm_shaping_profile_cir0;
   rand uvm_mem tm_shaping_profile_eir0;
   rand uvm_mem tm_wdrr_sch_ctrl0;
   rand uvm_mem tm_fill_tb_dst0;
   rand uvm_mem tm_pri_sch_ctrl00;
   rand uvm_mem tm_pri_sch_ctrl01;
   rand uvm_mem tm_pri_sch_ctrl02;
   rand uvm_mem tm_pri_sch_ctrl03;
   rand uvm_mem tm_pri_sch_ctrl04;
   rand uvm_mem tm_pri_sch_ctrl05;
   rand uvm_mem tm_pri_sch_ctrl06;
   rand uvm_mem tm_pri_sch_ctrl07;

   rand uvm_mem tm_queue_profile1;
   rand uvm_mem tm_wdrr_quantum1;
   rand uvm_mem tm_shaping_profile_cir1;
   rand uvm_mem tm_shaping_profile_eir1;
   rand uvm_mem tm_wdrr_sch_ctrl1;
   rand uvm_mem tm_fill_tb_dst1;
   rand uvm_mem tm_pri_sch_ctrl10;
   rand uvm_mem tm_pri_sch_ctrl11;
   rand uvm_mem tm_pri_sch_ctrl12;
   rand uvm_mem tm_pri_sch_ctrl13;
   rand uvm_mem tm_pri_sch_ctrl14;
   rand uvm_mem tm_pri_sch_ctrl15;
   rand uvm_mem tm_pri_sch_ctrl16;
   rand uvm_mem tm_pri_sch_ctrl17;

   rand uvm_mem tm_queue_profile2;
   rand uvm_mem tm_wdrr_quantum2;
   rand uvm_mem tm_shaping_profile_cir2;
   rand uvm_mem tm_shaping_profile_eir2;
   rand uvm_mem tm_wdrr_sch_ctrl2;
   rand uvm_mem tm_fill_tb_dst2;
   rand uvm_mem tm_pri_sch_ctrl20;
   rand uvm_mem tm_pri_sch_ctrl21;
   rand uvm_mem tm_pri_sch_ctrl22;
   rand uvm_mem tm_pri_sch_ctrl23;
   rand uvm_mem tm_pri_sch_ctrl24;
   rand uvm_mem tm_pri_sch_ctrl25;
   rand uvm_mem tm_pri_sch_ctrl26;
   rand uvm_mem tm_pri_sch_ctrl27;

   rand uvm_mem tm_queue_profile3;
   rand uvm_mem tm_wdrr_quantum3;
   rand uvm_mem tm_shaping_profile_cir3;
   rand uvm_mem tm_shaping_profile_eir3;
   rand uvm_mem tm_wdrr_sch_ctrl3;
   rand uvm_mem tm_fill_tb_dst3;
   rand uvm_mem tm_pri_sch_ctrl30;
   rand uvm_mem tm_pri_sch_ctrl31;
   rand uvm_mem tm_pri_sch_ctrl32;
   rand uvm_mem tm_pri_sch_ctrl33;
   rand uvm_mem tm_pri_sch_ctrl34;
   rand uvm_mem tm_pri_sch_ctrl35;
   rand uvm_mem tm_pri_sch_ctrl36;
   rand uvm_mem tm_pri_sch_ctrl37;

   uvm_reg_map reg_map;
 
   function new( string name = "tm_mem_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      tm_queue_association = new( .name( "tm_queue_association"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`QUEUE_ASSOCIATION_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_queue_association.configure( .parent( this ) );

      tm_queue_profile0 = new( .name( "tm_queue_profile0"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`FIRST_LVL_QUEUE_PROFILE_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_queue_profile0.configure( .parent( this ) );
      tm_wdrr_quantum0 = new( .name( "tm_wdrr_quantum0"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`WDRR_QUANTUM_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_wdrr_quantum0.configure( .parent( this ) );
      tm_shaping_profile_cir0 = new( .name( "tm_shaping_profile_cir0"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`CIR_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_shaping_profile_cir0.configure( .parent( this ) );
      tm_shaping_profile_eir0 = new( .name( "tm_shaping_profile_eir0"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`EIR_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_shaping_profile_eir0.configure( .parent( this ) );
      tm_wdrr_sch_ctrl0 = new( .name( "tm_wdrr_sch_ctrl0"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`WDRR_N_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_wdrr_sch_ctrl0.configure( .parent( this ) );
      tm_fill_tb_dst0 = new( .name( "tm_fill_tb_dst0"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`PORT_ID_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_fill_tb_dst0.configure( .parent( this ) );
      tm_pri_sch_ctrl00 = new( .name( "tm_pri_sch_ctrl00"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`FIRST_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl00.configure( .parent( this ) );
      tm_pri_sch_ctrl01 = new( .name( "tm_pri_sch_ctrl01"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`FIRST_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl01.configure( .parent( this ) );
      tm_pri_sch_ctrl02 = new( .name( "tm_pri_sch_ctrl02"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`FIRST_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl02.configure( .parent( this ) );
      tm_pri_sch_ctrl03 = new( .name( "tm_pri_sch_ctrl03"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`FIRST_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl03.configure( .parent( this ) );
      tm_pri_sch_ctrl04 = new( .name( "tm_pri_sch_ctrl04"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`FIRST_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl04.configure( .parent( this ) );
      tm_pri_sch_ctrl05 = new( .name( "tm_pri_sch_ctrl05"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`FIRST_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl05.configure( .parent( this ) );
      tm_pri_sch_ctrl06 = new( .name( "tm_pri_sch_ctrl06"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`FIRST_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl06.configure( .parent( this ) );
      tm_pri_sch_ctrl07 = new( .name( "tm_pri_sch_ctrl07"), .size((1<<`FIRST_LVL_QUEUE_ID_NBITS)), .n_bits(`FIRST_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl07.configure( .parent( this ) );

      tm_queue_profile1 = new( .name( "tm_queue_profile1"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`SECOND_LVL_QUEUE_PROFILE_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_queue_profile1.configure( .parent( this ) );
      tm_wdrr_quantum1 = new( .name( "tm_wdrr_quantum1"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`WDRR_QUANTUM_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_wdrr_quantum1.configure( .parent( this ) );
      tm_shaping_profile_cir1 = new( .name( "tm_shaping_profile_cir1"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`CIR_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_shaping_profile_cir1.configure( .parent( this ) );
      tm_shaping_profile_eir1 = new( .name( "tm_shaping_profile_eir1"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`EIR_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_shaping_profile_eir1.configure( .parent( this ) );
      tm_wdrr_sch_ctrl1 = new( .name( "tm_wdrr_sch_ctrl1"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`WDRR_N_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_wdrr_sch_ctrl1.configure( .parent( this ) );
      tm_fill_tb_dst1 = new( .name( "tm_fill_tb_dst1"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`PORT_ID_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_fill_tb_dst1.configure( .parent( this ) );
      tm_pri_sch_ctrl10 = new( .name( "tm_pri_sch_ctrl10"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`SECOND_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl10.configure( .parent( this ) );
      tm_pri_sch_ctrl11 = new( .name( "tm_pri_sch_ctrl11"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`SECOND_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl11.configure( .parent( this ) );
      tm_pri_sch_ctrl12 = new( .name( "tm_pri_sch_ctrl12"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`SECOND_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl12.configure( .parent( this ) );
      tm_pri_sch_ctrl13 = new( .name( "tm_pri_sch_ctrl13"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`SECOND_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl13.configure( .parent( this ) );
      tm_pri_sch_ctrl14 = new( .name( "tm_pri_sch_ctrl14"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`SECOND_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl14.configure( .parent( this ) );
      tm_pri_sch_ctrl15 = new( .name( "tm_pri_sch_ctrl15"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`SECOND_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl15.configure( .parent( this ) );
      tm_pri_sch_ctrl16 = new( .name( "tm_pri_sch_ctrl16"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`SECOND_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl16.configure( .parent( this ) );
      tm_pri_sch_ctrl17 = new( .name( "tm_pri_sch_ctrl17"), .size((1<<`SECOND_LVL_QUEUE_ID_NBITS)), .n_bits(`SECOND_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl17.configure( .parent( this ) );

      tm_queue_profile2 = new( .name( "tm_queue_profile2"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`THIRD_LVL_QUEUE_PROFILE_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_queue_profile2.configure( .parent( this ) );
      tm_wdrr_quantum2 = new( .name( "tm_wdrr_quantum2"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`WDRR_QUANTUM_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_wdrr_quantum2.configure( .parent( this ) );
      tm_shaping_profile_cir2 = new( .name( "tm_shaping_profile_cir2"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`CIR_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_shaping_profile_cir2.configure( .parent( this ) );
      tm_shaping_profile_eir2 = new( .name( "tm_shaping_profile_eir2"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`EIR_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_shaping_profile_eir2.configure( .parent( this ) );
      tm_wdrr_sch_ctrl2 = new( .name( "tm_wdrr_sch_ctrl2"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`WDRR_N_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_wdrr_sch_ctrl2.configure( .parent( this ) );
      tm_fill_tb_dst2 = new( .name( "tm_fill_tb_dst2"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`PORT_ID_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_fill_tb_dst2.configure( .parent( this ) );
      tm_pri_sch_ctrl20 = new( .name( "tm_pri_sch_ctrl20"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`THIRD_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl20.configure( .parent( this ) );
      tm_pri_sch_ctrl21 = new( .name( "tm_pri_sch_ctrl21"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`THIRD_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl21.configure( .parent( this ) );
      tm_pri_sch_ctrl22 = new( .name( "tm_pri_sch_ctrl22"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`THIRD_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl22.configure( .parent( this ) );
      tm_pri_sch_ctrl23 = new( .name( "tm_pri_sch_ctrl23"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`THIRD_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl23.configure( .parent( this ) );
      tm_pri_sch_ctrl24 = new( .name( "tm_pri_sch_ctrl24"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`THIRD_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl24.configure( .parent( this ) );
      tm_pri_sch_ctrl25 = new( .name( "tm_pri_sch_ctrl25"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`THIRD_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl25.configure( .parent( this ) );
      tm_pri_sch_ctrl26 = new( .name( "tm_pri_sch_ctrl26"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`THIRD_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl26.configure( .parent( this ) );
      tm_pri_sch_ctrl27 = new( .name( "tm_pri_sch_ctrl27"), .size((1<<`THIRD_LVL_QUEUE_ID_NBITS)), .n_bits(`THIRD_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl27.configure( .parent( this ) );

      tm_queue_profile3 = new( .name( "tm_queue_profile3"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`FOURTH_LVL_QUEUE_PROFILE_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_queue_profile3.configure( .parent( this ) );
      tm_wdrr_quantum3 = new( .name( "tm_wdrr_quantum3"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`WDRR_QUANTUM_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_wdrr_quantum3.configure( .parent( this ) );
      tm_shaping_profile_cir3 = new( .name( "tm_shaping_profile_cir3"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`CIR_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_shaping_profile_cir3.configure( .parent( this ) );
      tm_shaping_profile_eir3 = new( .name( "tm_shaping_profile_eir3"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`EIR_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_shaping_profile_eir3.configure( .parent( this ) );
      tm_wdrr_sch_ctrl3 = new( .name( "tm_wdrr_sch_ctrl3"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`WDRR_N_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_wdrr_sch_ctrl3.configure( .parent( this ) );
      tm_fill_tb_dst3 = new( .name( "tm_fill_tb_dst3"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`PORT_ID_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_fill_tb_dst3.configure( .parent( this ) );
      tm_pri_sch_ctrl30 = new( .name( "tm_pri_sch_ctrl30"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`FOURTH_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl30.configure( .parent( this ) );
      tm_pri_sch_ctrl31 = new( .name( "tm_pri_sch_ctrl31"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`FOURTH_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl31.configure( .parent( this ) );
      tm_pri_sch_ctrl32 = new( .name( "tm_pri_sch_ctrl32"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`FOURTH_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl32.configure( .parent( this ) );
      tm_pri_sch_ctrl33 = new( .name( "tm_pri_sch_ctrl33"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`FOURTH_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl33.configure( .parent( this ) );
      tm_pri_sch_ctrl34 = new( .name( "tm_pri_sch_ctrl34"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`FOURTH_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl34.configure( .parent( this ) );
      tm_pri_sch_ctrl35 = new( .name( "tm_pri_sch_ctrl35"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`FOURTH_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl35.configure( .parent( this ) );
      tm_pri_sch_ctrl36 = new( .name( "tm_pri_sch_ctrl36"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`FOURTH_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl36.configure( .parent( this ) );
      tm_pri_sch_ctrl37 = new( .name( "tm_pri_sch_ctrl37"), .size((1<<`FOURTH_LVL_QUEUE_ID_NBITS)), .n_bits(`FOURTH_LVL_QUEUE_ID_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tm_pri_sch_ctrl37.configure( .parent( this ) );

      reg_map = create_map( .name( "reg_map" ), .base_addr( {`TM_BLOCK_ADDR, {(`TM_BLOCK_ADDR_LSB){1'b0}}} ), .n_bytes( 4 ), .endian( UVM_LITTLE_ENDIAN ) );

      reg_map.add_mem( .mem( tm_queue_association ), .offset( {`TM_QUEUE_ASSOCIATION, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );

      reg_map.add_mem( .mem( tm_queue_profile0 ), .offset( {`TM_QUEUE_PROFILE0, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_wdrr_quantum0 ), .offset( {`TM_WDRR_QUANTUM0, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_shaping_profile_cir0 ), .offset( {`TM_SHAPING_PROFILE_CIR0, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_shaping_profile_eir0 ), .offset( {`TM_SHAPING_PROFILE_EIR0, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_wdrr_sch_ctrl0 ), .offset( {`TM_WDRR_SCH_CTRL0, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_fill_tb_dst0 ), .offset( {`TM_FILL_TB_DST0, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl00 ), .offset( {`TM_PRI_SCH_CTRL00, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl01 ), .offset( {`TM_PRI_SCH_CTRL01, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl02 ), .offset( {`TM_PRI_SCH_CTRL02, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl03 ), .offset( {`TM_PRI_SCH_CTRL03, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl04 ), .offset( {`TM_PRI_SCH_CTRL04, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl05 ), .offset( {`TM_PRI_SCH_CTRL05, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl06 ), .offset( {`TM_PRI_SCH_CTRL06, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl07 ), .offset( {`TM_PRI_SCH_CTRL07, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );

      reg_map.add_mem( .mem( tm_queue_profile1 ), .offset( {`TM_QUEUE_PROFILE1, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_wdrr_quantum1 ), .offset( {`TM_WDRR_QUANTUM1, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_shaping_profile_cir1 ), .offset( {`TM_SHAPING_PROFILE_CIR1, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_shaping_profile_eir1 ), .offset( {`TM_SHAPING_PROFILE_EIR1, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_wdrr_sch_ctrl1 ), .offset( {`TM_WDRR_SCH_CTRL1, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_fill_tb_dst1 ), .offset( {`TM_FILL_TB_DST1, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl10 ), .offset( {`TM_PRI_SCH_CTRL10, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl11 ), .offset( {`TM_PRI_SCH_CTRL11, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl12 ), .offset( {`TM_PRI_SCH_CTRL12, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl13 ), .offset( {`TM_PRI_SCH_CTRL13, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl14 ), .offset( {`TM_PRI_SCH_CTRL14, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl15 ), .offset( {`TM_PRI_SCH_CTRL15, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl16 ), .offset( {`TM_PRI_SCH_CTRL16, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl17 ), .offset( {`TM_PRI_SCH_CTRL17, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );

      reg_map.add_mem( .mem( tm_queue_profile2 ), .offset( {`TM_QUEUE_PROFILE2, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_wdrr_quantum2 ), .offset( {`TM_WDRR_QUANTUM2, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_shaping_profile_cir2 ), .offset( {`TM_SHAPING_PROFILE_CIR2, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_shaping_profile_eir2 ), .offset( {`TM_SHAPING_PROFILE_EIR2, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_wdrr_sch_ctrl2 ), .offset( {`TM_WDRR_SCH_CTRL2, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_fill_tb_dst2 ), .offset( {`TM_FILL_TB_DST2, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl20 ), .offset( {`TM_PRI_SCH_CTRL20, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl21 ), .offset( {`TM_PRI_SCH_CTRL21, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl22 ), .offset( {`TM_PRI_SCH_CTRL22, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl23 ), .offset( {`TM_PRI_SCH_CTRL23, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl24 ), .offset( {`TM_PRI_SCH_CTRL24, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl25 ), .offset( {`TM_PRI_SCH_CTRL25, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl26 ), .offset( {`TM_PRI_SCH_CTRL26, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl27 ), .offset( {`TM_PRI_SCH_CTRL27, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );

      reg_map.add_mem( .mem( tm_queue_profile3 ), .offset( {`TM_QUEUE_PROFILE3, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_wdrr_quantum3 ), .offset( {`TM_WDRR_QUANTUM3, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_shaping_profile_cir3 ), .offset( {`TM_SHAPING_PROFILE_CIR3, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_shaping_profile_eir3 ), .offset( {`TM_SHAPING_PROFILE_EIR3, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_wdrr_sch_ctrl3 ), .offset( {`TM_WDRR_SCH_CTRL3, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_fill_tb_dst3 ), .offset( {`TM_FILL_TB_DST3, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl30 ), .offset( {`TM_PRI_SCH_CTRL30, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl31 ), .offset( {`TM_PRI_SCH_CTRL31, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl32 ), .offset( {`TM_PRI_SCH_CTRL32, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl33 ), .offset( {`TM_PRI_SCH_CTRL33, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl34 ), .offset( {`TM_PRI_SCH_CTRL34, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl35 ), .offset( {`TM_PRI_SCH_CTRL35, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl36 ), .offset( {`TM_PRI_SCH_CTRL36, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );
      reg_map.add_mem( .mem( tm_pri_sch_ctrl37 ), .offset( {`TM_PRI_SCH_CTRL37, {(`TM_MEM_ADDR_LSB){1'b0}}}), .rights( "RW") );

      lock_model(); 
   endfunction: build
 
endclass