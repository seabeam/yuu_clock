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

  protected real   m_slow_freq;
  protected real   m_fast_freq;
  protected real   m_duty;
  protected string m_clock_unit;
  protected bit    m_clk_now;

  `uvm_component_utils(yuu_clock_driver)

  extern         function      new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task          run_phase(uvm_phase phase);
  extern virtual task          init_component();
  extern virtual task          count_time();
  extern virtual task          delay_unit(real delay);
endclass

function yuu_clock_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_clock_driver::build_phase(uvm_phase phase);
  if (cfg == null)
    `uvm_fatal("build_phase", "Check the yuu_clock agent configure setting")
endfunction

function void yuu_clock_driver::connect_phase(uvm_phase phase);
  vif = cfg.vif;
  events = cfg.events;
endfunction

task yuu_clock_driver::run_phase(uvm_phase phase);
  init_component();

  m_clk_now   = cfg.init_val;
  #(cfg.get_phase());
  m_slow_freq = cfg.get_slow_freq();
  m_fast_freq = cfg.get_fast_freq();
  m_duty      = cfg.get_duty();
  m_clock_unit= cfg.get_unit();
  vif.divide_num  <= cfg.divide_num;
  vif.multi_factor<= cfg.multi_factor;
  vif.ready       <= 1'b1;

  forever begin
    if (vif.enable === 1'b0 && cfg.gating_enable) begin
      vif.clk_o <= 1'b0;
      wait(vif.enable === 1'b1);
    end
    else
      count_time();
  end
endtask


task yuu_clock_driver::init_component();
  uvm_event init_done = events.get($sformatf("%s_init_done", cfg.get_name()));

  init_done.wait_on();
  cfg.check_valid();
  if (cfg.divider_mode || cfg.multiplier_mode) begin
    cfg.init_val = 1'b1;
  end
  vif.clk_o <= cfg.init_val;
  vif.divide_num  <= 'h0;
  vif.multi_factor<= 'h0;
  vif.ready       <= 1'b0;
endtask

task yuu_clock_driver::count_time();
  if (m_clk_now == 1'b1) begin
    if (vif.slow === 1'b1 && cfg.slow_enable)
      delay_unit(real'(1000)/m_slow_freq * m_duty);
    else
      delay_unit(real'(1000)/m_fast_freq * m_duty);
    vif.clk_o <= 1'b0;
    m_clk_now = 1'b0;
  end
  else if (m_clk_now == 1'b0) begin
    if (vif.slow === 1'b1 && cfg.slow_enable)
      delay_unit(real'(1000)/m_slow_freq * (real'(1)-m_duty));
    else
      delay_unit(real'(1000)/m_fast_freq * (real'(1)-m_duty));
    vif.clk_o <= 1'b1;
    m_clk_now = 1'b1;
  end
endtask

task yuu_clock_driver::delay_unit(real delay);
  real unit;

  case(m_clock_unit)
    "G":     unit = 1ps;
    "M":     unit = 1ns;
    "K":     unit = 1us;
    default: unit = 1ms;
  endcase
  
  #(delay*unit);
endtask

`endif