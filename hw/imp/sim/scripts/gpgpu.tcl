# Copyright 2023 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Author: Simone Machetti - simone.machetti@epfl.ch

source $env(GPGPU_HOME)/hw/imp/sim/scripts/compile_gpgpu.tcl

if {$env(SEL_MEM_HIER) == "CACHE"} {
    vlog -work work $lib_include $lib_vx_rtl $lib_vx_tex_unit $lib_vx_libs $lib_vx_interfaces $lib_vx_fp_cores $lib_vx_cache $env(GPGPU_HOME)/hw/src/tb/dual_port_ram.sv
    vlog -work work $lib_include $lib_vx_rtl $lib_vx_tex_unit $lib_vx_libs $lib_vx_interfaces $lib_vx_fp_cores $lib_vx_cache $env(GPGPU_HOME)/hw/src/tb/tb_cache.sv
} else {
    vlog -work work $lib_include $lib_vx_rtl $lib_vx_tex_unit $lib_vx_libs $lib_vx_interfaces $lib_vx_fp_cores $lib_vx_cache $env(GPGPU_HOME)/hw/src/tb/tb_scratchpad.sv
}

vsim -gui -wlf ./build/gpgpu.wlf work.testbench -voptargs="+acc"

if {!$env(SEL_SIM_GUI)} {
run -all
exit
}
