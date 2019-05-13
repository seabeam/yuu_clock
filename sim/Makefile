clean:
	@rm .[a-zA-Z]* -rf
	@ls | grep -v Makefile | grep -v top.sv | xargs rm -rf
	@echo clean down

comp:
	vcs -sverilog -full64 -q -ntb_opts uvm -debug_all ../include/clock_interface.svi ../include/clock_pkg.sv +incdir+../src/sv top.sv -timescale=1ns/1ps -l  comp.log

run:
	simv -gui -l run.log&
