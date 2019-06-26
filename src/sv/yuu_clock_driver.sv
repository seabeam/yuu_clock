/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_CLOCK_DRIVER_SV
`define YUU_CLOCK_DRIVER_SV

class yuu_clock_driver extends uvm_driver#(uvm_sequence_item);
  virtual yuu_clock_interface vif;
  
  yuu_clock_config cfg;
  uvm_event_pool events;

  protected real slow_freq;
  protected real fast_freq;
  protected bit clk_now;

  `uvm_component_utils(yuu_clock_driver)

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

  task reset_phase(uvm_phase phase);
    if (cfg.divider_mode)
      vif.clk_o <= vif.clk_i;
    else
      vif.clk_o <= cfg.init_val;
    vif.divide_num <= cfg.divide_num;
    clk_now = vif.clk_o;
    slow_freq = cfg.get_slow_freq();
    fast_freq = cfg.get_fast_freq();
  endtask

  task main_phase(uvm_phase phase);
    cfg.check_valid();
    forever begin
      if (vif.enable === 1'b0 && cfg.gating_enable) begin
        vif.clk_o <= 1'b0;
        wait(vif.enable === 1'b1);
      end
      else
        count_time();
    end
  endtask

  task count_time();
    if (cfg.divider_mode) begin
      repeat (cfg.divide_num/2) @(posedge vif.clk_i);
      vif.clk_o = ~vif.clk_o;
    end
    else begin
      if (clk_now == 1'b1) begin
        if (vif.slow === 1'b1 && cfg.slow_enable)
          #(real'(1000)/slow_freq * cfg.get_duty());
        else
          #(real'(1000)/fast_freq * cfg.get_duty());
        vif.clk_o <= 1'b0;
        clk_now = 1'b0;
      end
      else if (clk_now == 1'b0) begin
        if (vif.slow === 1'b1 && cfg.slow_enable)
          #(real'(1000)/slow_freq * (real'(1)-cfg.get_duty()));
        else
          #(real'(1000)/fast_freq * (real'(1)-cfg.get_duty()));
        vif.clk_o <= 1'b1;
        clk_now = 1'b1;
      end
    end
  endtask
endclass

`endif
