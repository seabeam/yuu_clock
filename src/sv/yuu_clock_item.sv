/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2020 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_CLOCK_ITEM_SV
`define YUU_CLOCK_ITEM_SV

class yuu_clock_item extends uvm_sequence_item;
  yuu_clock_config cfg;

  real    freq;
  real    duty;
  string  unit;

  `uvm_object_utils_begin(yuu_clock_item)
    `uvm_field_real   (freq, UVM_ALL_ON)
    `uvm_field_real   (duty, UVM_ALL_ON)
    `uvm_field_string (unit, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="yuu_clock_item");
    super.new(name);
  endfunction

endclass

`endif
