/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef CLOCK_AGENT_SV
`define CLOCK_AGENT_SV

class clock_agent extends uvm_agent;
  clock_agent_config cfg;

  clock_driver  driver;
  clock_monitor monitor;

  `uvm_component_utils(clock_agent)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(clock_agent_config)::get(null, get_full_name(), "cfg", cfg))
      `uvm_fatal("CFGDB", "Cannot get clock agent config")

    if (cfg.is_active == UVM_ACTIVE) begin
      driver = clock_driver::type_id::create("driver", this);
      driver.cfg = cfg;
    end
    monitor = clock_monitor::type_id::create("monitor", this);
    monitor.cfg = cfg;
  endfunction
endclass

`endif
