/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"

import yuu_common_pkg::*;
import yuu_clock_pkg::*;

class uvc_test extends uvm_test;
  virtual yuu_clock_interface vif;
  uvm_event_pool events;

  yuu_clock_agent agent;

  `uvm_component_utils(uvc_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    yuu_clock_config cfg = new("cfg");

    events = new("events");
    uvm_config_db#(virtual yuu_clock_interface)::get(null, get_full_name(), "vif", cfg.vif);
    cfg.set_freq(72, 32);
    cfg.set_duty(0.3);
    cfg.enable_clock_slow(True);
    cfg.enable_clock_gating(True);
    cfg.events = events;
    uvm_config_db#(yuu_clock_config)::set(this, "agent", "cfg", cfg);
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
  yuu_clock_interface cif();

  initial begin
    uvm_config_db#(virtual yuu_clock_interface)::set(null, "", "vif", cif);
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
