clean:
	@rm .[a-zA-Z]* -rf
	@ls | grep -v Makefile | grep -v top.sv | xargs rm -rf
	@echo clean down

comp:
	vcs -sverilog -full64 -q -ntb_opts uvm -debug_access+all ../../yuu_common/include/yuu_common_pkg.sv ../include/yuu_clock_pkg.sv +incdir+../../yuu_common/src/sv +incdir+../src/sv +incdir+../include top.sv -timescale=1ns/1ns -l comp.log

run:
	simv -gui -l run.log&
