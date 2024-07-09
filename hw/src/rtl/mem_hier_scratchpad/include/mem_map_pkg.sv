// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

package mem_map_pkg;

    typedef struct packed {
        logic [31:0] idx;
        logic [31:0] start_addr;
        logic [31:0] end_addr;
    } mem_map_t;

    localparam logic [31:0] RAM_BANK_SIZE = 32'h8000;

    localparam logic [31:0] INSTR_RAM_IDX           = 32'd0;
    localparam logic [31:0] INSTR_RAM_START_ADDRESS = 32'h00000000;
    localparam logic [31:0] INSTR_RAM_END_ADDRESS   = 32'h00008000;

    localparam logic [31:0] DATA_RAM_IDX           = 32'd0;
    localparam logic [31:0] DATA_RAM_START_ADDRESS = 32'h00008000;
    localparam logic [31:0] DATA_RAM_END_ADDRESS   = 32'h00028000;

    localparam logic [31:0] OFFSET_DATA_RAM0_IDX           = 32'd0;
    localparam logic [31:0] OFFSET_DATA_RAM0_START_ADDRESS = 32'h00000000;
    localparam logic [31:0] OFFSET_DATA_RAM0_END_ADDRESS   = 32'h00008000;

    localparam logic [31:0] OFFSET_DATA_RAM1_IDX           = 32'd1;
    localparam logic [31:0] OFFSET_DATA_RAM1_START_ADDRESS = 32'h00008000;
    localparam logic [31:0] OFFSET_DATA_RAM1_END_ADDRESS   = 32'h00010000;

    localparam logic [31:0] OFFSET_DATA_RAM2_IDX           = 32'd2;
    localparam logic [31:0] OFFSET_DATA_RAM2_START_ADDRESS = 32'h00010000;
    localparam logic [31:0] OFFSET_DATA_RAM2_END_ADDRESS   = 32'h00018000;

    localparam logic [31:0] OFFSET_DATA_RAM3_IDX           = 32'd3;
    localparam logic [31:0] OFFSET_DATA_RAM3_START_ADDRESS = 32'h00018000;
    localparam logic [31:0] OFFSET_DATA_RAM3_END_ADDRESS   = 32'h00020000;

    localparam mem_map_t [3:0] DATA_RAM_RULES = '{
        '{idx: OFFSET_DATA_RAM0_IDX, start_addr: OFFSET_DATA_RAM0_START_ADDRESS, end_addr: OFFSET_DATA_RAM0_END_ADDRESS},
        '{idx: OFFSET_DATA_RAM1_IDX, start_addr: OFFSET_DATA_RAM1_START_ADDRESS, end_addr: OFFSET_DATA_RAM1_END_ADDRESS},
        '{idx: OFFSET_DATA_RAM2_IDX, start_addr: OFFSET_DATA_RAM2_START_ADDRESS, end_addr: OFFSET_DATA_RAM2_END_ADDRESS},
        '{idx: OFFSET_DATA_RAM3_IDX, start_addr: OFFSET_DATA_RAM3_START_ADDRESS, end_addr: OFFSET_DATA_RAM3_END_ADDRESS}
    };

endpackage
