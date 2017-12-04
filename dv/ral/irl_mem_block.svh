class irl_mem_block extends uvm_reg_block;
   `uvm_object_utils( irl_mem_block )
 
   rand uvm_mem irl_cir_mem;
   rand uvm_mem irl_eir_mem;

   uvm_reg_map reg_map;
 
   function new( string name = "irl_mem_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      irl_cir_mem = new( .name( "irl_cir_mem"), .size((1<<`LIMITER_NBITS)), .n_bits(`CIR_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      irl_cir_mem.configure( .parent( this ) );

      irl_eir_mem = new( .name( "irl_eir_mem"), .size((1<<`LIMITER_NBITS)), .n_bits(`CIR_NBITS<<1), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      irl_eir_mem.configure( .parent( this ) );

      reg_map = create_map( .name( "reg_map" ), .base_addr( {`IRL_BLOCK_ADDR, {(`IRL_BLOCK_ADDR_LSB){1'b0}}} ),
                            .n_bytes( 4 ), .endian( UVM_LITTLE_ENDIAN ) );

      reg_map.add_mem( .mem( irl_cir_mem ), .offset( {`IRL_LIMITING_PROFILE_CIR, {(`IRL_MEM_ADDR_LSB-`LIMITER_NBITS-2){1'b0}}, {(`LIMITER_NBITS+2){1'b0}}} ), .rights( "RW" ) );
      reg_map.add_mem( .mem( irl_eir_mem ), .offset( {`IRL_LIMITING_PROFILE_EIR, {(`IRL_MEM_ADDR_LSB-`LIMITER_NBITS-2){1'b0}}, {(`LIMITER_NBITS+2){1'b0}}} ), .rights( "RW" ) );

      lock_model(); 
   endfunction: build
 
endclass
