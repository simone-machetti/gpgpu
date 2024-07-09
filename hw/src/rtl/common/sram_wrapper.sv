// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module sram_wrapper #(
    parameter MEM_SIZE_BYTE = 32768
)(
    input logic clk_i,
    input logic rst_ni,

    obi_req_if.slave  req,
    obi_rsp_if.master rsp
);

    sram_behavioral #(
        .MEM_SIZE_BYTE (MEM_SIZE_BYTE)
    ) sram_behavioral_i (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .req           (req),
        .rsp           (rsp)
    );

endmodule
