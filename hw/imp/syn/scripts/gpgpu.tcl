# Copyright 2023 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Author: Simone Machetti - simone.machetti@epfl.ch

source $env(GPGPU_HOME)/hw/imp/syn/scripts/compile_gpgpu.tcl

elaborate gpgpu_top
link

create_clock -name "clk" -period 1000 [ get_ports clk_i ]

write -f ddc -hierarchy -output precompiled.ddc

compile_ultra -no_autoungroup -no_boundary_optimization -timing -gate_clock

write -f ddc -hierarchy -output compiled.ddc

change_names -rules verilog -hier

write_file -pg -format verilog -hier -o $env(GPGPU_HOME)/hw/imp/syn/output/netlist.v

report_timing -nosplit > $env(GPGPU_HOME)/hw/imp/syn/report/timing.rpt
report_area -hier -nosplit > $env(GPGPU_HOME)/hw/imp/syn/report/area.rpt
report_power > $env(GPGPU_HOME)/hw/imp/syn/report/power.rpt

exit
