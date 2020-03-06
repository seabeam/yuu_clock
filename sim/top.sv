/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"

import yuu_common_pkg::*;
import yuu_clock_pkg::*;

class uvc_test extends uvm_test;
  virtual yuu_clock_interface clk_vif0;
  virtual yuu_clock_interface clk_vif1;
  virtual yuu_clock_interface clk_vif2;
  virtual yuu_clock_interface clk_vif3;
  uvm_event_pool events;

  yuu_clock_agent agent0;
  yuu_clock_agent agent1;
  yuu_clock_agent agent2;
  yuu_clock_agent agent3;

  `uvm_component_utils(uvc_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    yuu_clock_config cfg0 = new("cfg0");
    yuu_clock_config cfg1 = new("cfg1");
    yuu_clock_config cfg2 = new("cfg2");
    yuu_clock_config cfg3 = new("cfg3");

    events = new("events");
    uvm_config_db#(virtual yuu_clock_interface)::get(null, get_full_name(), "vif0", cfg0.vif);
    clk_vif0 = cfg0.vif;
    cfg0.set_freq(2, 1);
    cfg0.set_duty(0.3);
    cfg0.set_unit("M");
    cfg0.init_val = 1'b0;
    cfg0.enable_clock_slow(True);
    cfg0.enable_clock_gating(True);
    cfg0.events = events;
    uvm_config_db#(yuu_clock_config)::set(this, "agent0", "cfg", cfg0);
    agent0 = new("agent0", this);

    uvm_config_db#(virtual yuu_clock_interface)::get(null, get_full_name(), "vif1", cfg1.vif);
    clk_vif1 = cfg1.vif;
    cfg1.set_freq(800);
    cfg1.set_duty(0.5);
    cfg1.set_phase(4000);
    cfg1.set_unit("K");
    cfg1.init_val = 1'b1;
    cfg1.enable_clock_slow(False);
    cfg1.enable_clock_gating(False);
    cfg1.events = events;
    uvm_config_db#(yuu_clock_config)::set(this, "agent1", "cfg", cfg1);
    agent1 = new("agent1", this);

    uvm_config_db#(virtual yuu_clock_interface)::get(null, get_full_name(), "vif2", cfg2.vif);
    clk_vif2 = cfg2.vif;
    cfg2.multiplier_mode = True;
    cfg2.enable_clock_slow(False);
    cfg2.enable_clock_gating(False);
    cfg2.events = events;
    cfg2.multi_factor = 3;
    uvm_config_db#(yuu_clock_config)::set(this, "agent2", "cfg", cfg2);
    agent2 = new("agent2", this);

    uvm_config_db#(virtual yuu_clock_interface)::get(null, get_full_name(), "vif3", cfg3.vif);
    clk_vif3 = cfg3.vif;
    cfg3.divider_mode = True;
    cfg3.enable_clock_slow(False);
    cfg3.enable_clock_gating(False);
    cfg3.events = events;
    cfg3.divide_num = 2;
    uvm_config_db#(yuu_clock_config)::set(this, "agent3", "cfg", cfg3);
    agent3 = new("agent3", this);
  endfunction

  task run_phase(uvm_phase phase);
    fork
      begin
        phase.raise_objection(this);
        repeat(100) @(posedge clk_vif3.clk_o);
        phase.drop_objection(this);
      end
      event_process();
    join
  endtask

  task event_process();
    uvm_event e0 = events.get("cfg_clock_slow");
    uvm_event e1 = events.get("cfg_clock_fast");

    fork
      while(1) begin
        e0.wait_trigger();
        $display("Clock slow @ %0t", $realtime());
      end
      while(1) begin
        e1.wait_trigger();
        $display("Clock fast @ %0t", $realtime());
      end
    join
  endtask
endclass

module top;
  yuu_clock_interface cif0();
  yuu_clock_interface cif1();
  yuu_clock_interface cif2();
  yuu_clock_interface cif3();

  initial begin
    uvm_config_db#(virtual yuu_clock_interface)::set(null, "", "vif0", cif0);
    uvm_config_db#(virtual yuu_clock_interface)::set(null, "", "vif1", cif1);
    uvm_config_db#(virtual yuu_clock_interface)::set(null, "", "vif2", cif2);
    uvm_config_db#(virtual yuu_clock_interface)::set(null, "", "vif3", cif3);
    run_test("uvc_test");
  end

  logic clk_ext;
  always begin
    if (clk_ext == 1)
      #200ns clk_ext = ~clk_ext;
    else
      #800ns clk_ext = ~clk_ext;
  end

  assign cif2.clk_i = clk_ext;
  assign cif3.clk_i = clk_ext;

  initial begin
    clk_ext = 0;

    cif0.measure_enable = 1;
    cif1.measure_enable = 1;
    cif2.measure_enable = 1;
    cif3.measure_enable = 1;
    cif0.enable = 1'b0;
    cif0.slow   = 1'b1;
    #5ns;
    cif0.enable = 1'b1;
    while(1) begin
      #600ns;
      cif0.slow   = $urandom();
      #500ns;
      cif0.enable = $urandom();
    end
  end
endmodule
