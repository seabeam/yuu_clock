/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_CLOCK_PKG_SV
`define YUU_CLOCK_PKG_SV

`include "yuu_clock_interface.svi"

package yuu_clock_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import yuu_common_pkg::*;

  `include "yuu_clock_config.sv"
  `include "yuu_clock_driver.sv"
  `include "yuu_clock_monitor.sv"
  `include "yuu_clock_agent.sv"
endpackage

`endif
