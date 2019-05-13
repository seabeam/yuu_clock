/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef CLOCK_MONITOR_SV
`define CLOCK_MONITOR_SV

class clock_monitor extends uvm_monitor;
  virtual clock_interface vif;
  
  uvm_event_pool events;
  clock_agent_config cfg;

  `uvm_component_utils(clock_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (cfg == null)
      `uvm_fatal("Null Object", "Check the clock agent configure setting")
    vif = cfg.vif;
    events = cfg.events;
  endfunction

  task main_phase(uvm_phase phase);
    fork
      enable_monitor();
      slow_monitor();
    join
  endtask

  task enable_monitor();
    uvm_event e0 = events.get($sformatf("%s_clock_enable", cfg.get_name()));
    uvm_event e1 = events.get($sformatf("%s_clock_gating", cfg.get_name()));

    forever begin
      @(vif.enable);
      if (vif.enable === 1'b1) begin
        e0.trigger();
        `uvm_info("Clock monitor", "Clock turn on", UVM_MEDIUM)
      end
      else if (vif.enable === 1'b0) begin
        e1.trigger();
        `uvm_info("Clock monitor", "Clock turn off", UVM_MEDIUM)
      end
    end
  endtask

  task slow_monitor();
    uvm_event e0 = events.get($sformatf("%s_clock_slow", cfg.get_name()));
    uvm_event e1 = events.get($sformatf("%s_clock_fast", cfg.get_name()));

    forever begin
      @(vif.slow);
      if (vif.slow === 1'b1) begin
        e0.trigger();
        `uvm_info("Clock monitor", "Clock turn down", UVM_MEDIUM)
      end
      else if (vif.slow === 1'b0) begin
        e1.trigger();
        `uvm_info("Clock monitor", "Clock turn up", UVM_MEDIUM)
      end
    end
  endtask
endclass

`endif
