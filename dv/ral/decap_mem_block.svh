class decap_mem_block extends uvm_reg_block;
   `uvm_object_utils( decap_mem_block )
 
   rand uvm_mem rci_hash_table0;
   rand uvm_mem rci_hash_table1;
   rand uvm_mem rci_value_table;

   uvm_reg_map reg_map;
 
   function new( string name = "decap_mem_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      rci_hash_table0 = new( .name( "rci_hash_table0"), .size((1<<`RCI_HASH_TABLE_DEPTH_NBITS)), .n_bits(`RCI_HASH_BUCKET_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      rci_hash_table0.configure( .parent( this ) );

      rci_hash_table1 = new( .name( "rci_hash_table1"), .size((1<<`RCI_HASH_TABLE_DEPTH_NBITS)), .n_bits(`RCI_HASH_BUCKET_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      rci_hash_table1.configure( .parent( this ) );

      rci_value_table = new( .name( "rci_value_table"), .size((1<<`RCI_VALUE_DEPTH_NBITS)), .n_bits(/*`RCI_VALUE_NBITS+64*/512), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      rci_value_table.configure( .parent( this ) );

      reg_map = create_map( .name( "reg_map" ), .base_addr( {`DECR_BLOCK_ADDR, {(`DECR_BLOCK_ADDR_LSB){1'b0}}} ),
                            .n_bytes( 4 ), .endian( UVM_LITTLE_ENDIAN ) );

      reg_map.add_mem( .mem( rci_hash_table0 ), .offset( {`DECR_RCI_HASH_TABLE, {(`DECR_MEM_ADDR_LSB-`RCI_HASH_TABLE_DEPTH_NBITS-2-1){1'b0}}, 1'b0, {(`RCI_HASH_TABLE_DEPTH_NBITS+2){1'b0}}} ), .rights( "RW" ) );
      reg_map.add_mem( .mem( rci_hash_table1 ), .offset( {`DECR_RCI_HASH_TABLE, {(`DECR_MEM_ADDR_LSB-`RCI_HASH_TABLE_DEPTH_NBITS-2-1){1'b0}}, 1'b1, {(`RCI_HASH_TABLE_DEPTH_NBITS+2){1'b0}}} ), .rights( "RW" ) );
      reg_map.add_mem( .mem( rci_value_table ), .offset( {`DECR_RCI_VALUE, {(`DECR_MEM_ADDR_LSB-`RCI_VALUE_DEPTH_NBITS-2){1'b0}}, {(`RCI_VALUE_DEPTH_NBITS+2){1'b0}}} ), .rights( "RW" ) );

      lock_model(); 
   endfunction: build
 
endclass
