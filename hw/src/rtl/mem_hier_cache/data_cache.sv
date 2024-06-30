// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module data_cache
(
    input logic clk_i,
    input logic rst_ni,

    VX_dcache_req_if.slave  core_req,
    VX_dcache_rsp_if.master core_rsp,

    VX_mem_req_if.master mem_req,
    VX_mem_rsp_if.slave  mem_rsp
);

    VX_cache #(
        .CACHE_ID         (1),
        .CACHE_SIZE       (`DCACHE_SIZE),
        .CACHE_LINE_SIZE  (`DCACHE_LINE_SIZE),
        .NUM_BANKS        (`DCACHE_NUM_BANKS),
        .NUM_PORTS        (`DCACHE_NUM_PORTS),
        .WORD_SIZE        (`DCACHE_WORD_SIZE),
        .NUM_REQS         (`DCACHE_NUM_REQS),
        .CREQ_SIZE        (`DCACHE_CREQ_SIZE),
        .CRSQ_SIZE        (`DCACHE_CRSQ_SIZE),
        .MSHR_SIZE        (`DCACHE_MSHR_SIZE),
        .MRSQ_SIZE        (`DCACHE_MRSQ_SIZE),
        .MREQ_SIZE        (`DCACHE_MREQ_SIZE),
        .WRITE_ENABLE     (1),
        .CORE_TAG_WIDTH   (`DCACHE_CORE_TAG_WIDTH-`SM_ENABLE),
        .CORE_TAG_ID_BITS (`DCACHE_CORE_TAG_ID_BITS-`SM_ENABLE),
        .MEM_TAG_WIDTH    (`DCACHE_MEM_TAG_WIDTH),
        .NC_ENABLE        (1)
    ) data_cache_i (
        .clk              (clk_i),
        .reset            (~rst_ni),
        .core_req_valid   (core_req.valid),
        .core_req_rw      (core_req.rw),
        .core_req_byteen  (core_req.byteen),
        .core_req_addr    (core_req.addr),
        .core_req_data    (core_req.data),
        .core_req_tag     (core_req.tag),
        .core_req_ready   (core_req.ready),
        .core_rsp_valid   (core_rsp.valid),
        .core_rsp_tmask   (core_rsp.tmask),
        .core_rsp_data    (core_rsp.data),
        .core_rsp_tag     (core_rsp.tag),
        .core_rsp_ready   (core_rsp.ready),
        .mem_req_valid    (mem_req.valid),
        .mem_req_rw       (mem_req.rw),
        .mem_req_byteen   (mem_req.byteen),
        .mem_req_addr     (mem_req.addr),
        .mem_req_data     (mem_req.data),
        .mem_req_tag      (mem_req.tag),
        .mem_req_ready    (mem_req.ready),
        .mem_rsp_valid    (mem_rsp.valid),
        .mem_rsp_data     (mem_rsp.data),
        .mem_rsp_tag      (mem_rsp.tag),
        .mem_rsp_ready    (mem_rsp.ready)
    );

endmodule
