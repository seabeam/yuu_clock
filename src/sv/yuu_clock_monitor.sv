/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_CLOCK_MONITOR_SV
`define YUU_CLOCK_MONITOR_SV

class yuu_clock_monitor extends uvm_monitor;
  virtual yuu_clock_interface vif;
  
  yuu_clock_config cfg;
  uvm_event_pool events;

  `uvm_component_utils(yuu_clock_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (cfg == null)
      `uvm_fatal("build_phase", "Check the yuu_clock agent configure setting")
  endfunction

  function void connect_phase(uvm_phase phase);
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
    uvm_event e0 = events.get($sformatf("%s_yuu_clock_enable", cfg.get_name()));
    uvm_event e1 = events.get($sformatf("%s_yuu_clock_gating", cfg.get_name()));

    forever begin
      @(vif.enable);
      if (vif.enable === 1'b1) begin
        e0.trigger();
        `uvm_info("enable_monitor", $sformatf("%s clock turn on", cfg.get_name()), UVM_MEDIUM)
      end
      else if (vif.enable === 1'b0) begin
        e1.trigger();
        `uvm_info("enable_monitor", $sformatf("%s clock turn off", cfg.get_name()), UVM_MEDIUM)
      end
    end
  endtask

  task slow_monitor();
    uvm_event e0 = events.get($sformatf("%s_yuu_clock_slow", cfg.get_name()));
    uvm_event e1 = events.get($sformatf("%s_yuu_clock_fast", cfg.get_name()));

    forever begin
      @(vif.slow);
      if (vif.slow === 1'b1) begin
        e0.trigger();
        `uvm_info("slow_monitor", $sformatf("%s clock turn down", cfg.get_name()), UVM_MEDIUM)
      end
      else if (vif.slow === 1'b0) begin
        e1.trigger();
        `uvm_info("slow_monitor", $sformatf("%s clock turn up", cfg.get_name()), UVM_MEDIUM)
      end
    end
  endtask
endclass

`endif
