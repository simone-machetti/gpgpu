// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module gpgpu_top #(
`ifndef CACHE

    parameter INSTR_MEM_SIZE_BYTE = 32768,
    parameter DATA_MEM_SIZE_BYTE  = 131072,
    parameter DATA_MEM_NUM_BANKS  = 4

`endif
)(

`ifdef CACHE

    obi_req_if.master instr_mem_req,
    obi_rsp_if.slave  instr_mem_rsp,

    obi_req_if.master data_mem_req,
    obi_rsp_if.slave  data_mem_rsp,

`endif

    input logic clk_i,
    input logic rst_ni
);

    VX_icache_req_if #(
        .WORD_SIZE (`ICACHE_WORD_SIZE),
        .TAG_WIDTH (`ICACHE_CORE_TAG_WIDTH)
    ) instr_req();

    VX_icache_rsp_if #(
        .WORD_SIZE (`ICACHE_WORD_SIZE),
        .TAG_WIDTH (`ICACHE_CORE_TAG_WIDTH)
    ) instr_rsp();

    VX_dcache_req_if #(
        .NUM_REQS  (`DCACHE_NUM_REQS),
        .WORD_SIZE (`DCACHE_WORD_SIZE),
        .TAG_WIDTH (`DCACHE_CORE_TAG_WIDTH)
    ) data_req();

    VX_dcache_rsp_if #(
        .NUM_REQS  (`DCACHE_NUM_REQS),
        .WORD_SIZE (`DCACHE_WORD_SIZE),
        .TAG_WIDTH (`DCACHE_CORE_TAG_WIDTH)
    ) data_rsp();

    core core_i (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .instr_cache_req (instr_req),
        .instr_cache_rsp (instr_rsp),
        .data_cache_req  (data_req),
        .data_cache_rsp  (data_rsp)
    );

`ifdef CACHE

    mem_hier_cache_top mem_hier_cache_top_i (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .instr_cache_req (instr_req),
        .instr_cache_rsp (instr_rsp),
        .data_cache_req  (data_req),
        .data_cache_rsp  (data_rsp),
        .instr_mem_req   (instr_mem_req),
        .instr_mem_rsp   (instr_mem_rsp),
        .data_mem_req    (data_mem_req),
        .data_mem_rsp    (data_mem_rsp)
    );

`else

    mem_hier_scratchpad_top #(
        .INSTR_MEM_SIZE_BYTE  (INSTR_MEM_SIZE_BYTE),
        .DATA_MEM_SIZE_BYTE   (DATA_MEM_SIZE_BYTE),
        .DATA_MEM_NUM_BANKS   (DATA_MEM_NUM_BANKS)
    ) mem_hier_scratchpad_top_i (
        .clk_i                (clk_i),
        .rst_ni               (rst_ni),
        .instr_scratchpad_req (instr_req),
        .instr_scratchpad_rsp (instr_rsp),
        .data_scratchpad_req  (data_req),
        .data_scratchpad_rsp  (data_rsp)
    );

`endif

endmodule
