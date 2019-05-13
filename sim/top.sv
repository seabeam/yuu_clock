/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"

import clock_pkg::*;

class uvc_test extends uvm_test;
  virtual clock_interface vif;
  uvm_event_pool events;

  clock_agent agent;

  `uvm_component_utils(uvc_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    clock_agent_config cfg = new("cfg");

    events = new("events");
    uvm_config_db#(virtual clock_interface)::get(null, get_full_name(), "vif", cfg.vif);
    cfg.set_freq(72, 32);
    cfg.set_duty(0.3);
    cfg.enable_clock_slow(1);
    cfg.enable_clock_gating(1);
    cfg.events = events;
    uvm_config_db#(clock_agent_config)::set(this, "agent", "cfg", cfg);
    agent = new("agent", this);
  endfunction

  task main_phase(uvm_phase phase);
    fork
      begin
        phase.raise_objection(this);
        #10000;
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
  clock_interface cif();

  initial begin
    uvm_config_db#(virtual clock_interface)::set(null, "", "vif", cif);
    run_test("uvc_test");
  end

  initial begin
    cif.enable = 1'b0;
    cif.slow   = 1'b1;
    #55;
    cif.enable = 1'b1;
    while(1) begin
      #60;
      cif.slow   = $urandom();
      #50;
      cif.enable = $urandom();
    end
  end
endmodule
