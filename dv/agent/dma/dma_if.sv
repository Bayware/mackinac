`include "defines.vh"

interface dma_if (

   input wire         clk,
   input wire         reset_n,
   inout wire  [63:0] data,
   inout wire         valid,
   inout wire         last,
   inout wire         ready
   );

   clocking drv_cb @(posedge clk);
      default input #10ps output #10ps;
      output        data;
      output        valid;
      output        last;
      input         ready;
   endclocking: drv_cb

   clocking mon_cb @(posedge clk);
      default input #10ps output #10ps;
      input        data;
      input        valid;
      input        last;
   endclocking: mon_cb

endinterface
