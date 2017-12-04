class class_mem_block extends uvm_reg_block;
   `uvm_object_utils( class_mem_block )
 
   rand uvm_mem flow_hash_table0;
   rand uvm_mem flow_hash_table1;
   rand uvm_mem topic_hash_table0;
   rand uvm_mem topic_hash_table1;

   uvm_reg_map reg_map;
 
   function new( string name = "class_mem_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      flow_hash_table0 = new( .name( "flow_hash_table0"), .size((1<<`FLOW_HASH_TABLE_DEPTH_NBITS)), .n_bits(`FLOW_HASH_BUCKET_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      flow_hash_table0.configure( .parent( this ) );

      flow_hash_table1 = new( .name( "flow_hash_table1"), .size((1<<`FLOW_HASH_TABLE_DEPTH_NBITS)), .n_bits(`FLOW_HASH_BUCKET_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      flow_hash_table1.configure( .parent( this ) );

      topic_hash_table0 = new( .name( "topic_hash_table0"), .size((1<<`TOPIC_HASH_TABLE_DEPTH_NBITS)), .n_bits(`TOPIC_HASH_BUCKET_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      topic_hash_table0.configure( .parent( this ) );

      topic_hash_table1 = new( .name( "topic_hash_table1"), .size((1<<`TOPIC_HASH_TABLE_DEPTH_NBITS)), .n_bits(`TOPIC_HASH_BUCKET_NBITS), .access("RW"), .has_coverage(UVM_NO_COVERAGE ) );
      topic_hash_table1.configure( .parent( this ) );

      reg_map = create_map( .name( "reg_map" ), .base_addr( {`CLASSIFIER_BLOCK_ADDR, {(`CLASSIFIER_BLOCK_ADDR_LSB){1'b0}}} ),
                            .n_bytes( 4 ), .endian( UVM_LITTLE_ENDIAN ) );

      reg_map.add_mem( .mem( flow_hash_table0 ), .offset( {`CLASSIFIER_FLOW_HASH_TABLE, {(`CLASSIFIER_MEM_ADDR_LSB-`FLOW_HASH_TABLE_DEPTH_NBITS-3-1){1'b0}}, 1'b0, {(`FLOW_HASH_TABLE_DEPTH_NBITS+3){1'b0}}} ), .rights( "RW" ) );
      reg_map.add_mem( .mem( flow_hash_table1 ), .offset( {`CLASSIFIER_FLOW_HASH_TABLE, {(`CLASSIFIER_MEM_ADDR_LSB-`FLOW_HASH_TABLE_DEPTH_NBITS-3-1){1'b0}}, 1'b1, {(`FLOW_HASH_TABLE_DEPTH_NBITS+3){1'b0}}} ), .rights( "RW" ) );
      reg_map.add_mem( .mem( topic_hash_table0 ), .offset( {`CLASSIFIER_TOPIC_HASH_TABLE, {(`CLASSIFIER_MEM_ADDR_LSB-`TOPIC_HASH_TABLE_DEPTH_NBITS-3-1){1'b0}}, 1'b0, {(`TOPIC_HASH_TABLE_DEPTH_NBITS+3){1'b0}}} ), .rights( "RW" ) );
      reg_map.add_mem( .mem( topic_hash_table1 ), .offset( {`CLASSIFIER_TOPIC_HASH_TABLE, {(`CLASSIFIER_MEM_ADDR_LSB-`TOPIC_HASH_TABLE_DEPTH_NBITS-3-1){1'b0}}, 1'b1, {(`TOPIC_HASH_TABLE_DEPTH_NBITS+3){1'b0}}} ), .rights( "RW" ) );

      lock_model(); 
   endfunction: build
 
endclass
