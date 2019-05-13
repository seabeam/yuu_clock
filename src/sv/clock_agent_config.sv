/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef CLOCK_AGENT_CONFIG_SV
`define CLOCK_AGENT_CONFIG_SV

class clock_agent_config extends uvm_object;
  virtual clock_interface vif;
  uvm_event_pool events;

  bit enable_slow  = 1'b0;
  bit enable_gating= 1'b0;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  bit init_val = 0;
  int unsigned slow_freq;
  int unsigned high_freq;

  protected real m_duty = 0.5;

  `uvm_object_utils(clock_agent_config)

  function new(string name="clock_agent_config");
    super.new(name);
  endfunction

  function void set_duty(real duty);
    if (duty >= 1 || duty <= 0)
      `uvm_warning("Overflow", "The clock duty cycle only can be set in range (0, 1), setting ignored")
    else begin
      this.m_duty = duty;
      `uvm_info("Clock configuration", $sformatf("The clock duty cycle set to %f", duty), UVM_MEDIUM)
    end
  endfunction

  function real get_duty();
    return this.m_duty;
  endfunction

  function void set_freq(int unsigned high, int unsigned slow=0);
    this.high_freq = high;
    this.slow_freq = slow;
    `uvm_info("Clock configuration", $sformatf("The clock frequency set to [high:%0d low:%0d])", high, slow), UVM_MEDIUM)
  endfunction

  function void enable_clock_slow(bit on_off);
    if (slow_freq <= 0) begin
      `uvm_error("Overflow", "The slow frequency should be set up 0 when clock slow down enable")
    end
    else begin
      string state = on_off ? "ON" : "OFF";

      this.enable_slow = on_off;
      `uvm_info("Clock configuration", $sformatf("The clock slow down function is %s", state), UVM_MEDIUM)
    end
  endfunction

  function void enable_clock_gating(bit on_off);
    string state = on_off ? "ON" : "OFF";

    this.enable_gating = on_off;
    `uvm_info("Clock configuration", $sformatf("The clock gating function is %s", state), UVM_MEDIUM)
  endfunction
endclass

`endif
