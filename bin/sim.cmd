
../bin/setenv
../bin/sim.uvm_pkg
vlog -work work -f ../bin/sim_uvm_pkg.f
vlog -work work -f ../../dv/env/core_env.f
vopt core_tb -designfile design.db -debug -o opt
vsim -qwavedb=+signal -c opt -uvmcontrol=all -voptargs=+acc=lprn+top +UVM_TESTNAME=core_test_pu0 +UVM_VERBOSITY=UVM_HIGH -l vsim.log -do "run 500000ns; quit -f"
visualizer -designfile design.db -wavefile qwave.db

