/* (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  class_pkg.sv
//   Owner:   G Walter
//   Date:    10/27/17
//
//   Summary:  package for classifier block-level tb & design
*/

package class_pkg;
    typedef bit [ 31:0 ] uint32_t;
    typedef enum { FAIL, PASS } pf_e;
    enum logic { RD = 1'b0, WR = 1'b1 } rd_wr_e; 
    enum logic { MISS = 1'b0, HIT = 1'b1 } hit_miss_e;

    localparam PIO_NBITS = 32;
    localparam CLASSIFIER_BLOCK_ADDR_LSB = 20;
    localparam logic [ 11:0 ] CLASSIFIER_BLOCK_ADDR = 12'd4;
    localparam CLASSIFIER_REG_BLOCK_ADDR_LSB = 8;
    localparam logic [ 23:0 ] CLASSIFIER_REG_BLOCK_ADDR = 24'h008003;

    // Ken's - localparam logic [ 11:0 ] CLASSIFIER_MEM_BLOCK_ADDR = 12'h004;
    localparam logic [ 9:0 ] CLASSIFIER_MEM_BLOCK_ADDR = 10'h004;
    localparam VAL_MEM_WIDTH = 4*72;

    localparam PIO_ADDR_MSB = PIO_NBITS - 1;
    localparam CLASSIFIER_PIO_MEM_ADDR_WIDTH = 22;

endpackage
