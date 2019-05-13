/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef CLOCK_DRIVER_SV
`define CLOCK_DRIVER_SV

class clock_driver extends uvm_driver#(uvm_sequence_item);
  virtual clock_interface vif;
  
  uvm_event_pool events;
  clock_agent_config cfg;

  protected bit clk_now;

  `uvm_component_utils(clock_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (cfg == null)
      `uvm_fatal("Null Object", "Check the clock agent configure setting")
    vif = cfg.vif;
    events = cfg.events;
  endfunction

  task reset_phase(uvm_phase phase);
    vif.clk = cfg.init_val;
    clk_now = vif.clk;
  endtask

  task main_phase(uvm_phase phase);
    forever begin
      if (vif.enable === 1'b0 && cfg.enable_gating) begin
        vif.clk <= 1'b0;
        wait(vif.enable === 1'b1);
      end
      else
        count_time();
    end
  endtask

  task count_time();
    if (clk_now == 1'b1) begin
      if (vif.slow === 1'b1 && cfg.enable_slow)
        #(real'(1000)/real'(cfg.slow_freq) * cfg.get_duty());
      else
        #(real'(1000)/real'(cfg.high_freq) * cfg.get_duty());
      vif.clk <= 1'b0;
      clk_now = 1'b0;
    end
    else if (clk_now == 1'b0) begin
      if (vif.slow === 1'b1 && cfg.enable_slow)
        #(real'(1000)/real'(cfg.slow_freq) * (real'(1)-cfg.get_duty()));
      else
        #(real'(1000)/real'(cfg.high_freq) * (real'(1)-cfg.get_duty()));
      vif.clk <= 1'b1;
      clk_now = 1'b1;
    end
  endtask
endclass

`endif
