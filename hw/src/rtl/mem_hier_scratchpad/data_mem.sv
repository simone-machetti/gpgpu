// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module data_mem #(
    parameter DATA_MEM_SIZE_BYTE = 131072,
    parameter DATA_MEM_NUM_BANKS = 4
)(
    input logic clk_i,
    input logic rst_ni,

    obi_req_if.slave  data_mem_req [DATA_MEM_NUM_BANKS],
    obi_rsp_if.master data_mem_rsp [DATA_MEM_NUM_BANKS]
);

    localparam DATA_MEM_SIZE_BANK_BYTE = DATA_MEM_SIZE_BYTE/DATA_MEM_NUM_BANKS;

    genvar i;
    generate
        for (i=0; i<DATA_MEM_NUM_BANKS; i++) begin : gen_block
            single_port_sram_wrapper #(
                .MEM_SIZE_BYTE (DATA_MEM_SIZE_BANK_BYTE)
            ) single_port_sram_wrapper_i (
                .clk_i         (clk_i),
                .rst_ni        (rst_ni),
                .req           (data_mem_req[i]),
                .rsp           (data_mem_rsp[i])
            );
        end
    endgenerate

endmodule
