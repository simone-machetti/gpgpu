// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module clk_gate_cell_wrapper
(
    input  logic clk_i,
    input  logic en_i,
    output logic clk_o
);

    clk_gate_cell_behavioral clk_gate_cell_behavioral_i (
        .clk_i        (clk_i),
        .en_i         (en_i),
        .scan_cg_en_i (1'b0),
        .clk_o        (clk_o)
    );

endmodule
