class encap_mem_block extends uvm_reg_block;
   `uvm_object_utils( encap_mem_block )
 
   rand uvm_mem tunnel_hash_table0;
   rand uvm_mem tunnel_hash_table1;
   rand uvm_mem tunnel_value_table;

   uvm_reg_map reg_map;
 
   function new( string name = "encap_mem_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      tunnel_hash_table0 = new( .name( "tunnel_hash_table0"), .size((1<<`TUNNEL_HASH_TABLE_DEPTH_NBITS)), .n_bits(`TUNNEL_HASH_BUCKET_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tunnel_hash_table0.configure( .parent( this ) );

      tunnel_hash_table1 = new( .name( "tunnel_hash_table1"), .size((1<<`TUNNEL_HASH_TABLE_DEPTH_NBITS)), .n_bits(`TUNNEL_HASH_BUCKET_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tunnel_hash_table1.configure( .parent( this ) );

      tunnel_value_table = new( .name( "tunnel_value_table"), .size((1<<`TUNNEL_VALUE_DEPTH_NBITS)), .n_bits(/*`TUNNEL_VALUE_NBITS+64*/512), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tunnel_value_table.configure( .parent( this ) );

      reg_map = create_map( .name( "reg_map" ), .base_addr( {`ENCR_BLOCK_ADDR, {(`ENCR_BLOCK_ADDR_LSB){1'b0}}} ),
                            .n_bytes( 4 ), .endian( UVM_LITTLE_ENDIAN ) );

      reg_map.add_mem( .mem( tunnel_hash_table0 ), .offset( {`ENCR_TUNNEL_HASH_TABLE, {(`ENCR_MEM_ADDR_LSB-`TUNNEL_HASH_TABLE_DEPTH_NBITS-2-1){1'b0}}, 1'b0, {(`TUNNEL_HASH_TABLE_DEPTH_NBITS+2){1'b0}}} ), .rights( "RW" ) );
      reg_map.add_mem( .mem( tunnel_hash_table1 ), .offset( {`ENCR_TUNNEL_HASH_TABLE, {(`ENCR_MEM_ADDR_LSB-`TUNNEL_HASH_TABLE_DEPTH_NBITS-2-1){1'b0}}, 1'b1, {(`TUNNEL_HASH_TABLE_DEPTH_NBITS+2){1'b0}}} ), .rights( "RW" ) );
      reg_map.add_mem( .mem( tunnel_value_table ), .offset( {`ENCR_TUNNEL_VALUE, {(`ENCR_MEM_ADDR_LSB-`TUNNEL_VALUE_DEPTH_NBITS-2){1'b0}}, {(`TUNNEL_VALUE_DEPTH_NBITS+2){1'b0}}} ), .rights( "RW" ) );

      lock_model(); 
   endfunction: build
 
endclass
