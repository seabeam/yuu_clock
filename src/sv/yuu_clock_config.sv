/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_CLOCK_CONFIG_SV
`define YUU_CLOCK_CONFIG_SV

class yuu_clock_config extends uvm_object;
  virtual yuu_clock_interface vif;
  uvm_event_pool events;

  boolean slow_enable  = False;
  boolean gating_enable= False;
  boolean divider_mode = False;
  boolean multiplier_mode = False;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  logic init_val = 1'b0;
  protected real    m_slow_freq;
  protected real    m_fast_freq;
  bit [7:0]         divide_num = 0;
  bit [7:0]         multi_factor = 0;
  protected real    m_duty = 0.5;
  protected string  m_unit = "M";

  `uvm_object_utils(yuu_clock_config)

  function new(string name="yuu_clock_config");
    super.new(name);
  endfunction

  function void set_duty(real duty);
    if (duty >= 1 || duty <= 0)
      `uvm_warning("set_duty", "The clock duty cycle only can be set in range (0, 1), setting ignored")
    else begin
      this.m_duty = duty;
      `uvm_info("set_duty", $sformatf("The clock duty cycle set to %f", duty), UVM_MEDIUM)
    end
  endfunction

  function real get_duty();
    return this.m_duty;
  endfunction

  function void set_freq(real fast, real slow=0);
    this.m_fast_freq = fast;
    this.m_slow_freq = slow;
    `uvm_info("set_freq", $sformatf("The clock frequency set to [fast:%0f low:%0f])", fast, slow), UVM_MEDIUM)
  endfunction

  function real get_freq();
    return get_fast_freq();
  endfunction

  function real get_fast_freq();
    return this.m_fast_freq;
  endfunction

  function real get_slow_freq();
    return this.m_slow_freq;
  endfunction

  function void enable_clock_slow(boolean on_off);
    string state = on_off ? "ON" : "OFF";

    this.slow_enable = on_off;
    `uvm_info("enable_clock_slow", $sformatf("The clock slow down function is %s", state), UVM_MEDIUM)
  endfunction

  function void enable_clock_gating(boolean on_off);
    string state = on_off ? "ON" : "OFF";

    this.gating_enable = on_off;
    `uvm_info("enable_clock_gating", $sformatf("The clock gating function is %s", state), UVM_MEDIUM)
  endfunction

  function void set_unit(string unit);
    m_unit = unit.toupper();
  endfunction

  function string get_unit();
    return m_unit;
  endfunction

  function boolean check_valid();
    if (m_slow_freq <= 0 && slow_enable) begin
      `uvm_fatal("check_valid", "The slow frequency should be set up 0 when clock slow down enable")
      return False;
    end
    if (m_slow_freq > m_fast_freq) begin
      `uvm_fatal("check_valid", "The slow frequency should be lower than fast frequency")
      return False;
    end
    if (divider_mode & multiplier_mode) begin
      `uvm_fatal("check_valid", "It cannot enable divider mode and multiplier mode at the same time")
      return False;
    end
    if (divide_num == 0 && divider_mode) begin
      `uvm_fatal("check_valid", "The divide number should be a positive data when divider mode is enable")
      return False;
    end
    if (multi_factor == 0 && multiplier_mode) begin
      `uvm_fatal("check_valid", "The multiply factor should be a positive data when multiplier mode is enable")
      return False;
    end
    if (!(m_unit inside {"", "K", "M", "G"})) begin
      `uvm_fatal("check_valid", "The acceptable clock time unit is empty string, K, M or G")
      return False;
    end

    return True;
  endfunction
endclass

`endif
