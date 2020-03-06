clean:
	@rm .[a-zA-Z]* -rf
	@ls | grep -v Makefile | grep -v top.sv | xargs rm -rf
	@echo clean done

comp:
	vcs -sverilog -full64 -lca -kdb -q -ntb_opts uvm -debug_access+all ../../yuu_common/include/yuu_common_pkg.sv ../include/yuu_clock_pkg.sv +incdir+../../yuu_common/include +incdir+../../yuu_common/src/sv +incdir+../src/sv/yuu_clock_agent +incdir+../include top.sv -timescale=1ps/1ps -l comp.log

run:
	simv -l run.log ${ADD}