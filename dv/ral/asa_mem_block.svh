class asa_mem_block extends uvm_reg_block;
   `uvm_object_utils( asa_mem_block )
 
   rand uvm_mem asa_sci_mem;

   uvm_reg_map reg_map;
 
   function new( string name = "asa_mem_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      asa_sci_mem = new( .name( "asa_sci_mem"), .size((1<<`RCI_NBITS)), .n_bits(`SCI_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      asa_sci_mem.configure( .parent( this ) );

      reg_map = create_map( .name( "reg_map" ), .base_addr( {`ASA_BLOCK_ADDR, {(`ASA_BLOCK_ADDR_LSB){1'b0}}} ),
                            .n_bytes( 4 ), .endian( UVM_LITTLE_ENDIAN ) );

      reg_map.add_mem( .mem( asa_sci_mem ), .offset( {`ASA_RCI2SCI_TABLE, {(`ASA_MEM_ADDR_LSB-`RCI_NBITS-2){1'b0}}, {(`RCI_NBITS+2){1'b0}}} ), .rights( "RW" ) );

      lock_model(); 
   endfunction: build
 
endclass
