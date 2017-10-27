/* (c) 2017 Bayware, Inc.
//
//   Project: Mackinac
//   Module:  testbench.sv
//   Owner:   G Walter
//   Date:    10/27/17
//
//   Summary:  block-level testbench for classifier.
*/

module tb;

localparam KEY_LEN = 276;
localparam ITEMS = 1024;
localparam BUS_WIDTH = 128;

import class_pkg::*;

    logic clk;
    logic rst_n;
    
    // instantiate interface
    class_intf
    #(
        .KEY_LEN(),
        .ITEMS(),
        .BUS_WIDTH()
    )
    theIF( .clk( clk ), .rst_n( rst_n ) );
    
    // instantiate main program
    main_prg
    #(
        .KEY_LEN( KEY_LEN ),
        .ITEMS( ITEMS )
    )
    u_main_prg
    (
        .i_f( theIF )
    );

    // instantiate classifier itself
    classifier u_classifier
    (
        .clk( clk ),
        .rst_n( rst_n ),
        .clsmp( theIF )
    );
    
    initial
    begin
        $timeformat( -9, 1, "ns", 8 );
    
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

endmodule

// =======================================================================
// Main Program

program automatic main_prg
#(
    parameter KEY_LEN = 276,
    parameter ITEMS = 512
)
(
    class_intf.TB i_f
);

    virtual class_intf#( .KEY_LEN( KEY_LEN ), .ITEMS( ITEMS ) ).TB sig_h = i_f;
    
    initial
    begin
        sig_h.rst_n <= 1'b0;
        #50 sig_h.rst_n <= 1'b1;
        repeat( 10 ) @( sig_h.cb );
    end

endprogram
