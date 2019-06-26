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

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  logic init_val = 1'b0;
  protected real slow_freq;
  protected real fast_freq;
  int unsigned divide_num = 0;
  protected real m_duty = 0.5;

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

  function void set_freq(int unsigned fast, int unsigned slow=0);
    this.fast_freq = fast;
    this.slow_freq = slow;
    `uvm_info("set_freq", $sformatf("The clock frequency set to [fast:%0d low:%0d])", fast, slow), UVM_MEDIUM)
  endfunction

  function real get_freq();
    return get_fast_freq();
  endfunction

  function real get_fast_freq();
    return this.fast_freq;
  endfunction

  function real get_slow_freq();
    return this.slow_freq;
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

  function boolean check_valid();
    if (slow_freq <= 0 && slow_enable) begin
      `uvm_fatal("check_valid", "The slow frequency should be set up 0 when clock slow down enable")
      return False;
    end
    if (slow_freq > fast_freq) begin
      `uvm_fatal("check_valid", "The slow frequency should be lower than fast frequency")
      return False;
    end
    if (divide_num == 0 && divider_mode) begin
      `uvm_fatal("check_valid", "The divide number should be a positive data when divider mode is enable")
    end

    return True;
  endfunction
endclass

`endif
