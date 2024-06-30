// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module mem_hier_cache_top
(
    input logic clk_i,
    input logic rst_ni,

    VX_icache_req_if.slave  instr_cache_req,
    VX_icache_rsp_if.master instr_cache_rsp,

    VX_dcache_req_if.slave  data_cache_req,
    VX_dcache_rsp_if.master data_cache_rsp,

    obi_req_if.master instr_mem_req,
    obi_rsp_if.slave  instr_mem_rsp,

    obi_req_if.master data_mem_req,
    obi_rsp_if.slave  data_mem_rsp
);

    localparam WORD_WIDTH_BIT = 32;
    localparam ADDR_WIDTH_BIT = 32;

    VX_mem_req_if #(
        .DATA_WIDTH (`ICACHE_MEM_DATA_WIDTH),
        .ADDR_WIDTH (`ICACHE_MEM_ADDR_WIDTH),
        .TAG_WIDTH  (`ICACHE_MEM_TAG_WIDTH)
    ) instr_serializer_req();

    VX_mem_rsp_if #(
        .DATA_WIDTH (`ICACHE_MEM_DATA_WIDTH),
        .TAG_WIDTH  (`ICACHE_MEM_TAG_WIDTH)
    ) instr_serializer_rsp();

    VX_mem_req_if #(
        .DATA_WIDTH (`DCACHE_MEM_DATA_WIDTH),
        .ADDR_WIDTH (`DCACHE_MEM_ADDR_WIDTH),
        .TAG_WIDTH  (`DCACHE_MEM_TAG_WIDTH)
    ) data_serializer_req();

    VX_mem_rsp_if #(
        .DATA_WIDTH (`DCACHE_MEM_DATA_WIDTH),
        .TAG_WIDTH  (`DCACHE_MEM_TAG_WIDTH)
    ) data_serializer_rsp();

    VX_mem_req_if #(
        .DATA_WIDTH (WORD_WIDTH_BIT),
        .ADDR_WIDTH (ADDR_WIDTH_BIT),
        .TAG_WIDTH  (`ICACHE_MEM_TAG_WIDTH)
    ) instr_obi_bridge_req();

    VX_mem_rsp_if #(
        .DATA_WIDTH (WORD_WIDTH_BIT),
        .TAG_WIDTH  (`ICACHE_MEM_TAG_WIDTH)
    ) instr_obi_bridge_rsp();

    VX_mem_req_if #(
        .DATA_WIDTH (WORD_WIDTH_BIT),
        .ADDR_WIDTH (ADDR_WIDTH_BIT),
        .TAG_WIDTH  (`DCACHE_MEM_TAG_WIDTH)
    ) data_obi_bridge_req();

    VX_mem_rsp_if #(
        .DATA_WIDTH (WORD_WIDTH_BIT),
        .TAG_WIDTH  (`DCACHE_MEM_TAG_WIDTH)
    ) data_obi_bridge_rsp();

    instr_cache instr_cache_i (
        .clk_i    (clk_i),
        .rst_ni   (rst_ni),
        .core_req (instr_cache_req),
        .core_rsp (instr_cache_rsp),
        .mem_req  (instr_serializer_req),
        .mem_rsp  (instr_serializer_rsp)
    );

    data_cache data_cache_i (
        .clk_i    (clk_i),
        .rst_ni   (rst_ni),
        .core_req (data_cache_req),
        .core_rsp (data_cache_rsp),
        .mem_req  (data_serializer_req),
        .mem_rsp  (data_serializer_rsp)
    );

    serializer #(
        .ADDR_WIDTH_BIT (`ICACHE_MEM_ADDR_WIDTH),
        .DATA_WIDTH_BIT (`ICACHE_MEM_DATA_WIDTH),
        .TAG_WIDTH_BIT  (`ICACHE_MEM_TAG_WIDTH)
    ) instr_serializer_i (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .in_mem_req     (instr_serializer_req),
        .in_mem_rsp     (instr_serializer_rsp),
        .out_mem_req    (instr_obi_bridge_req),
        .out_mem_rsp    (instr_obi_bridge_rsp)
    );

    serializer #(
        .ADDR_WIDTH_BIT (`DCACHE_MEM_ADDR_WIDTH),
        .DATA_WIDTH_BIT (`DCACHE_MEM_DATA_WIDTH),
        .TAG_WIDTH_BIT  (`DCACHE_MEM_TAG_WIDTH)
    ) data_serializer_i (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .in_mem_req     (data_serializer_req),
        .in_mem_rsp     (data_serializer_rsp),
        .out_mem_req    (data_obi_bridge_req),
        .out_mem_rsp    (data_obi_bridge_rsp)
    );

    obi_bridge #(
        .TAG_WIDTH_BIT (`ICACHE_MEM_TAG_WIDTH)
    ) instr_obi_bridge_i (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .vx_mem_req    (instr_obi_bridge_req),
        .vx_mem_rsp    (instr_obi_bridge_rsp),
        .obi_mem_req   (instr_mem_req),
        .obi_mem_rsp   (instr_mem_rsp)
    );

    obi_bridge #(
        .TAG_WIDTH_BIT (`DCACHE_MEM_TAG_WIDTH)
    ) data_obi_bridge_i (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .vx_mem_req    (data_obi_bridge_req),
        .vx_mem_rsp    (data_obi_bridge_rsp),
        .obi_mem_req   (data_mem_req),
        .obi_mem_rsp   (data_mem_rsp)
    );

endmodule
