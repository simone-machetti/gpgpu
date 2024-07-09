// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module vx_icache_to_obi_bridge #(
    parameter TAG_WIDTH_BIT = 1
)(
    input logic clk_i,
    input logic rst_ni,

    VX_icache_req_if.slave  vx_icache_req,
    VX_icache_rsp_if.master vx_icache_rsp,

    obi_req_if.master obi_req,
    obi_rsp_if.slave  obi_rsp
);

    typedef enum logic [1:0] {IDLE, OBI_SEND_REQ, OBI_WAIT_RSP, VX_SEND_RSP} state_t;

    state_t curr_state;
    state_t next_state;

    logic [31:0]              curr_vx_addr;
    logic [TAG_WIDTH_BIT-1:0] curr_vx_tag;

    logic [31:0]              next_vx_addr;
    logic [TAG_WIDTH_BIT-1:0] next_vx_tag;

    logic [31:0] curr_obi_rdata;
    logic [31:0] next_obi_rdata;

    logic store_vx;
    logic store_obi;

    logic vx_icache_req_ready;
    logic obi_req_req;
    logic vx_icache_rsp_valid;

    /*
    * Store input VX request
    */
    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            curr_vx_addr <= '0;
            curr_vx_tag  <= '0;
        end
        else begin
            curr_vx_addr <= next_vx_addr;
            curr_vx_tag  <= next_vx_tag;
        end
    end

    assign next_vx_addr = store_vx ? {vx_icache_req.addr, 2'b00} : curr_vx_addr;
    assign next_vx_tag  = store_vx ? vx_icache_req.tag  : curr_vx_tag;

    assign obi_req.addr = curr_vx_addr;

    assign vx_icache_rsp.tag = curr_vx_tag;

    /*
    * Store input OBI response
    */
    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni)
            curr_obi_rdata <= '0;
        else
            curr_obi_rdata <= next_obi_rdata;
    end

    assign next_obi_rdata = store_obi ? obi_rsp.rdata : curr_obi_rdata;

    assign vx_icache_rsp.data = curr_obi_rdata;

    /*
    * Send ready and valid signals
    */
    assign vx_icache_req.ready = vx_icache_req_ready;
    assign obi_req.req         = obi_req_req;
    assign vx_icache_rsp.valid = vx_icache_rsp_valid;

    /*
    * FSM
    */
    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    always_comb begin
        next_state          = curr_state;
        store_vx            = 1'b0;
        vx_icache_req_ready = 1'b0;
        obi_req_req         = 1'b0;
        store_obi           = 1'b0;
        vx_icache_rsp_valid = 1'b0;
        case (curr_state)
            IDLE: begin
                if (vx_icache_req.valid) begin
                    store_vx            = 1'b1;
                    vx_icache_req_ready = 1'b1;
                    next_state          = OBI_SEND_REQ;
                end
                else begin
                    next_state = IDLE;
                end
            end
            OBI_SEND_REQ: begin
                obi_req_req = 1'b1;
                if (obi_req.gnt) begin
                    next_state = OBI_WAIT_RSP;
                end
                else begin
                    next_state = OBI_SEND_REQ;
                end
            end
            OBI_WAIT_RSP: begin
                if (obi_rsp.rvalid) begin
                    store_obi  = 1'b1;
                    next_state = VX_SEND_RSP;
                end
                else begin
                    next_state = OBI_WAIT_RSP;
                end
            end
            VX_SEND_RSP: begin
                vx_icache_rsp_valid = 1'b1;
                if (vx_icache_rsp.ready) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = VX_SEND_RSP;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
