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

    obi_req_if.slave  instr_mem_req,
    obi_rsp_if.master instr_mem_rsp
);

    sram_wrapper #(
        .MEM_SIZE_BYTE (INSTR_MEM_SIZE_BYTE)
    ) sram_wrapper_i (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .req           (instr_mem_req),
        .rsp           (instr_mem_rsp)
    );

endmodule
