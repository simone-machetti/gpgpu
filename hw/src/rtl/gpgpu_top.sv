// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module gpgpu_top
(
    input logic clk_i,
    input logic rst_ni,

    obi_req_if.master instr_mem_req,
    obi_rsp_if.slave  instr_mem_rsp,

    obi_req_if.master data_mem_req,
    obi_rsp_if.slave  data_mem_rsp
);

    VX_icache_req_if #(
        .WORD_SIZE (`ICACHE_WORD_SIZE),
        .TAG_WIDTH (`ICACHE_CORE_TAG_WIDTH)
    ) instr_cache_req();

    VX_icache_rsp_if #(
        .WORD_SIZE (`ICACHE_WORD_SIZE),
        .TAG_WIDTH (`ICACHE_CORE_TAG_WIDTH)
    ) instr_cache_rsp();

    VX_dcache_req_if #(
        .NUM_REQS  (`DCACHE_NUM_REQS),
        .WORD_SIZE (`DCACHE_WORD_SIZE),
        .TAG_WIDTH (`DCACHE_CORE_TAG_WIDTH)
    ) data_cache_req();

    VX_dcache_rsp_if #(
        .NUM_REQS  (`DCACHE_NUM_REQS),
        .WORD_SIZE (`DCACHE_WORD_SIZE),
        .TAG_WIDTH (`DCACHE_CORE_TAG_WIDTH)
    ) data_cache_rsp();

    core core_i (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .instr_cache_req (instr_cache_req),
        .instr_cache_rsp (instr_cache_rsp),
        .data_cache_req  (data_cache_req),
        .data_cache_rsp  (data_cache_rsp)
    );

    mem_hier_cache_top mem_hier_cache_top_i (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .instr_cache_req (instr_cache_req),
        .instr_cache_rsp (instr_cache_rsp),
        .data_cache_req  (data_cache_req),
        .data_cache_rsp  (data_cache_rsp),
        .instr_mem_req   (instr_mem_req),
        .instr_mem_rsp   (instr_mem_rsp),
        .data_mem_req    (data_mem_req),
        .data_mem_rsp    (data_mem_rsp)
    );

endmodule
