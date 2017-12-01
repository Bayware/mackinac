
`include "defines.vh"

interface mac_if (

   input wire         clk,
   input wire         reset_n,
   inout wire  [31:0] data,
   inout wire         valid,
   inout wire         last,
   inout wire  [3:0]  keep,
   inout wire         user,
   inout wire         ready
   );

   clocking drv_cb @(posedge clk);
      default input #10ps output #10ps;
      output        data;
      output        valid;
      output        last;
      output        keep;
      output        user;
   endclocking: drv_cb

   clocking mon_cb @(posedge clk);
      default input #10ps output #10ps;
      input        data;
      input        valid;
      input        last;
      input        keep;
      input        user;
   endclocking: mon_cb

endinterface
