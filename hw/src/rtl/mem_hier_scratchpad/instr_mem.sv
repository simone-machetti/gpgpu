// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module instr_mem #(
    parameter INSTR_MEM_SIZE_BYTE = 32768
)(
    input logic clk_i,
    input logic rst_ni,

    obi_req_if.slave  instr_mem_req_0,
    obi_rsp_if.master instr_mem_rsp_0,

    obi_req_if.slave  instr_mem_req_1,
    obi_rsp_if.master instr_mem_rsp_1
);

    double_port_sram_wrapper #(
        .MEM_SIZE_BYTE (INSTR_MEM_SIZE_BYTE)
    ) double_port_sram_wrapper_i (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .req_0         (instr_mem_req_0),
        .rsp_0         (instr_mem_rsp_0),
        .req_1         (instr_mem_req_1),
        .rsp_1         (instr_mem_rsp_1)
    );

endmodule
