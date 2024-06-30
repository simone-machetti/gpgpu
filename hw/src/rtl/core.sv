// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module core
(
    input logic clk_i,
    input logic rst_ni,

    VX_icache_req_if.master instr_cache_req,
    VX_icache_rsp_if.slave  instr_cache_rsp,

    VX_dcache_req_if.master data_cache_req,
    VX_dcache_rsp_if.slave  data_cache_rsp
);

    VX_pipeline #(
        .CORE_ID(0)
    ) vortex_core_i (
        .clk               (clk_i),
        .reset             (~rst_ni),
        .icache_req_valid  (instr_cache_req.valid),
        .icache_req_addr   (instr_cache_req.addr),
        .icache_req_tag    (instr_cache_req.tag),
        .icache_req_ready  (instr_cache_req.ready),
        .icache_rsp_valid  (instr_cache_rsp.valid),
        .icache_rsp_data   (instr_cache_rsp.data),
        .icache_rsp_tag    (instr_cache_rsp.tag),
        .icache_rsp_ready  (instr_cache_rsp.ready),
        .dcache_req_valid  (data_cache_req.valid),
        .dcache_req_rw     (data_cache_req.rw),
        .dcache_req_byteen (data_cache_req.byteen),
        .dcache_req_addr   (data_cache_req.addr),
        .dcache_req_data   (data_cache_req.data),
        .dcache_req_tag    (data_cache_req.tag),
        .dcache_req_ready  (data_cache_req.ready),
        .dcache_rsp_valid  (data_cache_rsp.valid),
        .dcache_rsp_tmask  (data_cache_rsp.tmask),
        .dcache_rsp_data   (data_cache_rsp.data),
        .dcache_rsp_tag    (data_cache_rsp.tag),
        .dcache_rsp_ready  (data_cache_rsp.ready),
        .busy              ()
    );

endmodule
