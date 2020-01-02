/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_CLOCK_AGENT_SV
`define YUU_CLOCK_AGENT_SV

class yuu_clock_agent extends uvm_agent;
  yuu_clock_config cfg;

  yuu_clock_driver  driver;
  yuu_clock_monitor monitor;

  uvm_analysis_port #(yuu_clock_item) out_monitor_ap;
  
  `uvm_component_utils(yuu_clock_agent)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db #(yuu_clock_config)::get(null, get_full_name(), "cfg", cfg))
      `uvm_fatal("build_phase", "Cannot get clock configuration")
    if (cfg == null)
      `uvm_fatal("build_phase", "Get a null clock configuration")

    if (cfg.is_active == UVM_ACTIVE) begin
      driver = yuu_clock_driver::type_id::create("driver", this);
      driver.cfg = cfg;
    end
    monitor = yuu_clock_monitor::type_id::create("monitor", this);
    monitor.cfg = cfg;
  endfunction

  function void connect_phase(uvm_phase phase);
    out_monitor_ap = monitor.out_monitor_ap;
  endfunction
endclass

`endif
