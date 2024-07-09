// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module sram_behavioral #(
    parameter MEM_SIZE_BYTE = 32768
)(
    input logic clk_i,
    input logic rst_ni,

    obi_req_if.slave  req,
    obi_rsp_if.master rsp
);

    localparam MEM_SIZE_WORD = MEM_SIZE_BYTE*4;

    logic [31:0] mem_array [0:MEM_SIZE_WORD-1];

    typedef enum logic [1:0] {IDLE, READ, WRITE} state_t;

    state_t curr_state;
    state_t next_state;

    logic [3:0]  be;
    logic [$clog2(MEM_SIZE_BYTE)-3:0] addr;
    logic [31:0] wdata;

    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            be    <= '0;
            addr  <= '0;
            wdata <= '0;
        end
        else begin
            be    <= req.be;
            addr  <= req.addr[$clog2(MEM_SIZE_BYTE)-1:2];
            wdata <= req.wdata;
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            curr_state <= IDLE;
        end
        else begin
            curr_state <= next_state;
        end
    end

    always_comb begin
        next_state = curr_state;
        req.gnt    = 1'b0;
        rsp.rvalid = 1'b0;
        rsp.rdata  = 32'd0;
        case(curr_state)
            IDLE: begin
                if (req.req) begin
                    if (req.we) begin
                        req.gnt    = 1'b1;
                        next_state = WRITE;
                    end
                    else begin
                        req.gnt    = 1'b1;
                        next_state = READ;
                    end
                end
                else begin
                    next_state = IDLE;
                end
            end
            READ: begin
                rsp.rvalid = 1'b1;
                rsp.rdata  = mem_array[addr];
                next_state = IDLE;
            end
            WRITE: begin
                rsp.rvalid                 = 1'b1;
                if (be[0])
                    mem_array[addr][7:0]   = wdata[7:0];
                if (be[1])
                    mem_array[addr][15:8]  = wdata[15:8];
                if (be[2])
                    mem_array[addr][23:16] = wdata[23:16];
                if (be[3])
                    mem_array[addr][31:24] = wdata[31:24];
                next_state                 = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
