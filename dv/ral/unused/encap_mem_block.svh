class encap_mem_block extends uvm_reg_block;
   `uvm_object_utils( encap_mem_block )
 
   rand encap_tunnel_hash_table_mem tunnel_hash_table0;
   rand encap_tunnel_hash_table_mem tunnel_hash_table1;
   rand encap_tunnel_value_table_mem tunnel_value_table;

   uvm_mem tunnel_hash_mem0;
   uvm_mem tunnel_hash_mem1;
   uvm_mem tunnel_value_mem;

   uvm_reg_map reg_map;
 
   function new( string name = "encap_mem_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      tunnel_hash_mem0 = new( .name( "tunnel_hash_mem0"), .size((1<<`TUNNEL_HASH_TABLE_DEPTH_NBITS)), .n_bits(`TUNNEL_HASH_BUCKET_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tunnel_hash_mem0.configure( .parent( this ) );

      tunnel_hash_mem1 = new( .name( "tunnel_hash_mem1"), .size((1<<`TUNNEL_HASH_TABLE_DEPTH_NBITS)), .n_bits(`TUNNEL_HASH_BUCKET_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tunnel_hash_mem1.configure( .parent( this ) );

      tunnel_value_mem = new( .name( "tunnel_value_mem"), .size((1<<`TUNNEL_VALUE_DEPTH_NBITS)), .n_bits(`TUNNEL_VALUE_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      tunnel_value_mem.configure( .parent( this ) );

      tunnel_hash_table0 = encap_tunnel_hash_table_mem::type_id::create( "tunnel_hash_table0" );
      tunnel_hash_table0.configure( .parent( this ), .mem(tunnel_hash_mem0), .size((1<<`TUNNEL_HASH_TABLE_DEPTH_NBITS)), .offset(0), .incr(1) );
      tunnel_hash_table0.build();
 
      tunnel_hash_table1 = encap_tunnel_hash_table_mem::type_id::create( "tunnel_hash_table1" );
      tunnel_hash_table1.configure( .parent( this ), .mem(tunnel_hash_mem1), .size((1<<`TUNNEL_HASH_TABLE_DEPTH_NBITS)), .offset(0), .incr(1) );
      tunnel_hash_table1.build();
 
      tunnel_value_table = encap_tunnel_value_table_mem::type_id::create( "tunnel_value_table" );
      tunnel_value_table.configure( .parent( this ), .mem(tunnel_value_mem), .size((1<<`TUNNEL_VALUE_DEPTH_NBITS)), .offset(0), .incr(1) );
      tunnel_value_table.build();
 
      reg_map = create_map( .name( "reg_map" ), .base_addr( {`ENCR_BLOCK_ADDR, {(`ENCR_BLOCK_ADDR_LSB){1'b0}}} ),
                            .n_bytes( 4 ), .endian( UVM_LITTLE_ENDIAN ) );

      reg_map.add_mem( .mem( tunnel_hash_mem0 ), .offset( {`ENCR_TUNNEL_HASH_TABLE, {(`ENCR_MEM_ADDR_LSB-`TUNNEL_HASH_TABLE_DEPTH_NBITS-2-1){1'b0}}, 1'b0, {(`TUNNEL_HASH_TABLE_DEPTH_NBITS+2){1'b0}}} ), .rights( "RW" ) );
      reg_map.add_mem( .mem( tunnel_hash_mem1 ), .offset( {`ENCR_TUNNEL_HASH_TABLE, {(`ENCR_MEM_ADDR_LSB-`TUNNEL_HASH_TABLE_DEPTH_NBITS-2-1){1'b0}}, 1'b1, {(`TUNNEL_HASH_TABLE_DEPTH_NBITS+2){1'b0}}} ), .rights( "RW" ) );
      reg_map.add_mem( .mem( tunnel_value_mem ), .offset( {`ENCR_TUNNEL_VALUE, {(`ENCR_MEM_ADDR_LSB-`TUNNEL_VALUE_DEPTH_NBITS-2){1'b0}}, {(`TUNNEL_VALUE_DEPTH_NBITS+2){1'b0}}} ), .rights( "RW" ) );

      lock_model(); 
   endfunction: build
 
endclass
