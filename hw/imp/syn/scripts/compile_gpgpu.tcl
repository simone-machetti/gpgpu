# Copyright 2023 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Author: Simone Machetti - simone.machetti@epfl.ch

remove_design -all

set target_library {}
set target_library "/dkits/tsmc/65nm/IP_65nm/LP/STDCELL_IO/tapeoutPackage/Front_End/timing_power_noise/CCS/tcbn65lplvt_200a/tcbn65lplvttc_ccs.db"
set link_library "/dkits/tsmc/65nm/IP_65nm/LP/STDCELL_IO/tapeoutPackage/Front_End/timing_power_noise/CCS/tcbn65lplvt_200a/tcbn65lplvttc_ccs.db"

# /hw/src/vendor/vortex/hw/rtl/cache
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/cache/VX_tag_access.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/cache/VX_shared_mem.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/cache/VX_nc_bypass.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/cache/VX_miss_resrv.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/cache/VX_flush_ctrl.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/cache/VX_data_access.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/cache/VX_core_rsp_merge.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/cache/VX_core_req_bank_sel.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/cache/VX_cache.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/cache/VX_bank.sv

# /hw/src/vendor/vortex/hw/rtl/interfaces
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_wstall_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_writeback_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_warp_ctl_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_tex_rsp_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_tex_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_tex_csr_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_perf_tex_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_perf_pipeline_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_perf_memsys_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_perf_cache_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_mem_rsp_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_mem_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_lsu_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_join_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_ifetch_rsp_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_ifetch_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_icache_rsp_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_icache_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_ibuffer_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_gpu_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_gpr_rsp_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_gpr_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_fpu_to_csr_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_fpu_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_fetch_to_csr_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_decode_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_dcache_rsp_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_dcache_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_csr_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_commit_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_cmt_to_csr_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_branch_ctl_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/interfaces/VX_alu_req_if.sv

# /hw/src/vendor/vortex/hw/rtl/libs
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_stream_demux.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_stream_arbiter.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_sp_ram.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_skid_buffer.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_shift_register.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_serial_div.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_scope.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_scan.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_rr_arbiter.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_reset_relay.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_priority_encoder.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_popcount.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_pipe_register.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_pending_size.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_onehot_mux.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_onehot_encoder.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_mux.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_multiplier.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_matrix_arbiter.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_lzc.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_index_queue.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_index_buffer.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_fixed_arbiter.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_find_first.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_fifo_queue.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_fair_arbiter.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_elastic_buffer.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_dp_ram.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_divider.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_bypass_buffer.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_bits_remove.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_bits_insert.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/libs/VX_axi_adapter.sv

# /hw/src/vendor/vortex/hw/rtl/tex_unit
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/tex_unit/VX_tex_wrap.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/tex_unit/VX_tex_unit.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/tex_unit/VX_tex_stride.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/tex_unit/VX_tex_sat.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/tex_unit/VX_tex_sampler.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/tex_unit/VX_tex_mem.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/tex_unit/VX_tex_lerp.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/tex_unit/VX_tex_format.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/tex_unit/VX_tex_addr.sv

# /hw/src/vendor/vortex/hw/rtl
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_writeback.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_warp_sched.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_smem_arb.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_scoreboard.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_muldiv.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_mem_unit.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_mem_arb.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_lsu_unit.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_issue.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_ipdom_stack.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_icache_stage.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_ibuffer.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_gpu_unit.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_gpr_stage.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_fetch.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_execute.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_dispatch.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_decode.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_csr_unit.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_csr_data.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_commit.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_cluster.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_cache_arb.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_alu_unit.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_core.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/vortex/hw/rtl/VX_pipeline.sv

# /hw/src/rtl/interfaces
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/interfaces/obi_req_if.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/interfaces/obi_rsp_if.sv

# /hw/src/rtl/common
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/common/sram_behavioral.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/common/sram_wrapper.sv

# /hw/src/rtl/mem_hier_cache
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_cache/vx_mem_to_obi_bridge.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_cache/serializer.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_cache/instr_cache.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_cache/data_cache.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_cache/mem_hier_cache_top.sv

# /hw/src/rtl/mem_hier_scratchpad/include
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_scratchpad/include/mem_map_pkg.sv

# /hw/src/vendor/pulp_platform_common_cells/src
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/pulp_platform_common_cells/src/rr_arb_tree.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/pulp_platform_common_cells/src/lzc.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/pulp_platform_common_cells/src/cf_math_pkg.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/pulp_platform_common_cells/src/addr_decode.sv

# /hw/src/vendor/pulp_platform_cluster_interconnect/rtl/tcdm_variable_latency_interconnect
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/pulp_platform_cluster_interconnect/rtl/tcdm_variable_latency_interconnect/addr_dec_resp_mux_varlat.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/vendor/pulp_platform_cluster_interconnect/rtl/tcdm_variable_latency_interconnect/xbar_varlat.sv

# /hw/src/rtl/mem_hier_scratchpad
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_scratchpad/vx_icache_to_obi_bridge.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_scratchpad/vx_dcache_to_obi_bridge.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_scratchpad/il_bus_interconnect.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_scratchpad/instr_mem.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_scratchpad/data_mem.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/mem_hier_scratchpad/mem_hier_scratchpad_top.sv

# /hw/src/rtl/
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/core.sv
analyze -format sverilog -work work $env(GPGPU_HOME)/hw/src/rtl/gpgpu_top.sv -define $env(SEL_MEM_HIER)
