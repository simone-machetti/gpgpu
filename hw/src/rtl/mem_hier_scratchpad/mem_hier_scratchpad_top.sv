// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module mem_hier_scratchpad_top
    import mem_map_pkg::*;
#(
    parameter INSTR_MEM_SIZE_BYTE = 32768,
    parameter DATA_MEM_SIZE_BYTE  = 131072,
    parameter DATA_MEM_NUM_BANKS  = 4
)(
    input logic clk_i,
    input logic rst_ni,

    VX_icache_req_if.slave  instr_scratchpad_req,
    VX_icache_rsp_if.master instr_scratchpad_rsp,

    VX_dcache_req_if.slave  data_scratchpad_req,
    VX_dcache_rsp_if.master data_scratchpad_rsp
);

    obi_req_if instr_mem_req();
    obi_rsp_if instr_mem_rsp();

    obi_req_if data_bus_interconnect_req [DATA_MEM_NUM_BANKS]();
    obi_rsp_if data_bus_interconnect_rsp [DATA_MEM_NUM_BANKS]();

    obi_req_if data_mem_req [DATA_MEM_NUM_BANKS]();
    obi_rsp_if data_mem_rsp [DATA_MEM_NUM_BANKS]();

    vx_icache_to_obi_bridge #(
        .TAG_WIDTH_BIT (`ICACHE_CORE_TAG_WIDTH)
    ) instr_vx_icache_to_obi_bridge_i (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .vx_icache_req (instr_scratchpad_req),
        .vx_icache_rsp (instr_scratchpad_rsp),
        .obi_req       (instr_mem_req),
        .obi_rsp       (instr_mem_rsp)
    );

    vx_dcache_to_obi_bridge #(
        .NUM_REQS      (`DCACHE_NUM_REQS),
        .TAG_WIDTH_BIT (`DCACHE_CORE_TAG_WIDTH)
    ) instr_vx_dcache_to_obi_bridge_i (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .vx_dcache_req (data_scratchpad_req),
        .vx_dcache_rsp (data_scratchpad_rsp),
        .obi_req       (data_bus_interconnect_req),
        .obi_rsp       (data_bus_interconnect_rsp)
    );

    il_bus_interconnect #(
        .NUM_MASTER     (`DCACHE_NUM_REQS),
        .NUM_SLAVE      (DATA_MEM_NUM_BANKS),
        .IL_ADDR_OFFSET (mem_map_pkg::DATA_RAM_START_ADDRESS),
        .IL_ADDR_SIZE   (mem_map_pkg::DATA_RAM_END_ADDRESS-mem_map_pkg::DATA_RAM_START_ADDRESS)
    ) data_il_bus_interconnect_i(
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .addr_map_i     (mem_map_pkg::DATA_RAM_RULES),
        .default_idx_i  (mem_map_pkg::OFFSET_DATA_RAM0_IDX[1:0]),
        .master_req     (data_bus_interconnect_req),
        .master_rsp     (data_bus_interconnect_rsp),
        .slave_req      (data_mem_req),
        .slave_rsp      (data_mem_rsp)
    );

    instr_mem #(
        .INSTR_MEM_SIZE_BYTE (INSTR_MEM_SIZE_BYTE)
    ) instr_mem_i (
        .clk_i               (clk_i),
        .rst_ni              (rst_ni),
        .instr_mem_req       (instr_mem_req),
        .instr_mem_rsp       (instr_mem_rsp)
    );

    data_mem #(
        .DATA_MEM_SIZE_BYTE (DATA_MEM_SIZE_BYTE),
        .DATA_MEM_NUM_BANKS (DATA_MEM_NUM_BANKS)
    ) data_mem_i (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .data_mem_req       (data_mem_req),
        .data_mem_rsp       (data_mem_rsp)
    );

endmodule
