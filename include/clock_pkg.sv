/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef CLOCK_PKG_SV
`define CLOCK_PKG_SV

package clock_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "clock_agent_config.sv"
  `include "clock_driver.sv"
  `include "clock_monitor.sv"
  `include "clock_agent.sv"
endpackage

`endif
