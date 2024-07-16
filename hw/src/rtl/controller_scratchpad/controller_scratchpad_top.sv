// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module controller_scratchpad_top
(
    input logic clk_i,
    input logic rst_ni,

    obi_req_if.slave  regs_req,
    obi_rsp_if.master regs_rsp,

    obi_req_if.master ext_instr_req,
    obi_rsp_if.slave  ext_instr_rsp,

    obi_req_if.master ext_data_req,
    obi_rsp_if.slave  ext_data_rsp,

    obi_req_if.master int_instr_req,
    obi_rsp_if.slave  int_instr_rsp,

    obi_req_if.master int_data_req,
    obi_rsp_if.slave  int_data_rsp,

    output logic clk_core_o,
    output logic rst_n_core_o
);

    logic clk_core_en;

    dma_ctrl_if dma_instr_ctrl();
    dma_ctrl_if dma_data_ctrl();

    clk_gate_cell_wrapper clk_gate_cell_wrapper_i (
        .clk_i (clk_i),
        .en_i  (clk_core_en),
        .clk_o (clk_core_o)
    );

    controller_scratchpad controller_scratchpad_i (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .regs_req       (regs_req),
        .regs_rsp       (regs_rsp),
        .clk_core_en_o  (clk_core_en),
        .rst_n_core_o   (rst_n_core_o),
        .dma_instr_ctrl (dma_instr_ctrl),
        .dma_data_ctrl  (dma_data_ctrl)
    );

    dma dma_i (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .ext_instr_req (ext_instr_req),
        .ext_instr_rsp (ext_instr_rsp),
        .ext_data_req  (ext_data_req),
        .ext_data_rsp  (ext_data_rsp),
        .int_instr_req (int_instr_req),
        .int_instr_rsp (int_instr_rsp),
        .int_data_req  (int_data_req),
        .int_data_rsp  (int_data_rsp),
        .instr_ctrl    (dma_instr_ctrl),
        .data_ctrl     (dma_data_ctrl)
    );

endmodule
