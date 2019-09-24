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

  task reset_phase(uvm_phase phase);
    real duty;
    real freq;
    string unit;

    phase.raise_objection(this, "Reset start");
    if (cfg.divider_mode || cfg.multiplier_mode) begin
      measure_input(duty, freq, unit);
      cfg.set_freq(freq);
      cfg.set_unit(unit);
      cfg.set_duty(duty);
    end
    phase.drop_objection(this, "Reset end");
  endtask

  task main_phase(uvm_phase phase);
    fork
      monitor_gating();
      monitor_slow();
    join
  endtask

  task monitor_gating();
    uvm_event e0 = events.get($sformatf("%s_yuu_clock_enable", cfg.get_name()));
    uvm_event e1 = events.get($sformatf("%s_yuu_clock_gating", cfg.get_name()));

    forever begin
      @(vif.enable);
      if (vif.enable === 1'b1) begin
        e0.trigger();
        `uvm_info("monitor_gating", $sformatf("%s clock turn on", cfg.get_name()), UVM_MEDIUM)
      end
      else if (vif.enable === 1'b0) begin
        e1.trigger();
        `uvm_info("monitor_gating", $sformatf("%s clock turn off", cfg.get_name()), UVM_MEDIUM)
      end
    end
  endtask

  task monitor_slow();
    uvm_event e0 = events.get($sformatf("%s_yuu_clock_slow", cfg.get_name()));
    uvm_event e1 = events.get($sformatf("%s_yuu_clock_fast", cfg.get_name()));

    forever begin
      @(vif.slow);
      if (vif.slow === 1'b1) begin
        e0.trigger();
        `uvm_info("monitor_slow", $sformatf("%s clock turn down", cfg.get_name()), UVM_MEDIUM)
      end
      else if (vif.slow === 1'b0) begin
        e1.trigger();
        `uvm_info("monitor_slow", $sformatf("%s clock turn up", cfg.get_name()), UVM_MEDIUM)
      end
    end
  endtask

  //    ---------          ----
  //    |       |          |
  //-----       ------------
  //   t0      t1         t2
  task measure_input(output real duty, output real freq, output string unit);
    real t0, t1, t2;

    wait(vif.clk_i === 1'b1);
    t0 = $realtime();
    $display(t0);
    wait(vif.clk_i === 1'b0);
    t1 = $realtime();
    $display(t1);
    wait(vif.clk_i === 1'b1);
    t2 = $realtime();
    $display(t2);
      
    if (cfg.multiplier_mode) begin
      reconfig_mult(t0, t1, t2, duty, freq, unit);
    end
    else begin
      reconfig_div(t0, t1, t2, duty, freq, unit);
    end
  endtask

  function void reconfig_mult(input  real t0,
                              input  real t1,
                              input  real t2,
                              output real duty, 
                              output real freq, 
                              output string unit);
    real T;
    real ofm;
    string time_unit = get_sim_time_unit();
    
    T = t2-t0;
    duty = (t1-t0)/T;
    ofm = $log10(T);
    if (ofm < 3) begin
      freq  = real'(1000)/T*real'(cfg.multi_factor);
      case(time_unit)
        "s":  unit = "";
        "ms": unit = "";
        "us": unit = "K";
        "ns": unit = "M";
        "ps": unit = "G";
        "fs": unit = "G";
      endcase
    end
    else if (ofm >= 3 && ofm < 6) begin
      freq = real'(1000)/(T/real'(1000))*real'(cfg.multi_factor);
      case(time_unit)
        "s":  unit = "";
        "ms": unit = "";
        "us": unit = "";
        "ns": unit = "K";
        "ps": unit = "M";
        "fs": unit = "G";
      endcase
    end
    else if (ofm >= 6 && ofm < 9) begin
      freq = real'(1000)/(T/real'(1000000))*real'(cfg.multi_factor);
      case(time_unit)
        "s":  unit = "";
        "ms": unit = "";
        "us": unit = "";
        "ns": unit = "";
        "ps": unit = "K";
        "fs": unit = "M";
      endcase
    end
    else begin
      freq = real'(1000)/(T/real'(1000000000))*real'(cfg.multi_factor);
      case(time_unit)
        "s":  unit = "";
        "ms": unit = "";
        "us": unit = "";
        "ns": unit = "";
        "ps": unit = "";
        "fs": unit = "K";
      endcase
    end
  endfunction

  function void reconfig_div(input  real t0,
                             input  real t1,
                             input  real t2,
                             output real duty, 
                             output real freq, 
                             output string unit);
    real T;
    real ofm;
    string time_unit = get_sim_time_unit();
    
    T = t2-t0;
    duty = (t1-t0)/T;
    ofm = $log10(T);
    if (ofm < 3) begin
      freq  = real'(1000)/T/real'(cfg.divide_num);
      case(time_unit)
        "s":  unit = "";
        "ms": unit = "";
        "us": unit = "K";
        "ns": unit = "M";
        "ps": unit = "G";
        "fs": unit = "G";
      endcase
    end
    else if (ofm >= 3 && ofm < 6) begin
      freq = real'(1000)/(T/real'(1000))/real'(cfg.divide_num);
      case(time_unit)
        "s":  unit = "";
        "ms": unit = "";
        "us": unit = "";
        "ns": unit = "K";
        "ps": unit = "M";
        "fs": unit = "G";
      endcase
    end
    else if (ofm >= 6 && ofm < 9) begin
      freq = real'(1000)/(T/real'(1000000))/real'(cfg.divide_num);
      case(time_unit)
        "s":  unit = "";
        "ms": unit = "";
        "us": unit = "";
        "ns": unit = "";
        "ps": unit = "K";
        "fs": unit = "M";
      endcase
    end
    else begin
      freq = real'(1000)/(T/real'(1000000000))/real'(cfg.divide_num);
      case(time_unit)
        "s":  unit = "";
        "ms": unit = "";
        "us": unit = "";
        "ns": unit = "";
        "ps": unit = "";
        "fs": unit = "K";
      endcase
    end
  endfunction

  function string get_sim_time_unit();
    int test_time;

    test_time = 100ms;
    if (test_time == 0)
      return "s";
    test_time = 100us;
    if (test_time == 0)
      return "ms";
    test_time = 100ns;
    if (test_time == 0)
      return "us";
    test_time = 100ps;
    if (test_time == 0)
      return "ns";
    test_time = 100fs;
    if (test_time == 0)
      return "ps";

    return "fs";
  endfunction
endclass

`endif
