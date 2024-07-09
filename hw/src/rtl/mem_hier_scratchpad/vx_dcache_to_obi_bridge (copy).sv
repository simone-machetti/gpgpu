// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module vx_dcache_to_obi_bridge #(
    parameter NUM_REQS      = 1,
    parameter TAG_WIDTH_BIT = 1
)(
    input logic clk_i,
    input logic rst_ni,

    VX_dcache_req_if.slave  vx_dcache_req,
    VX_dcache_rsp_if.master vx_dcache_rsp,

    obi_req_if.master obi_req [NUM_REQS],
    obi_rsp_if.slave  obi_rsp [NUM_REQS]
);

    typedef enum logic [1:0] {IDLE_VX, WAIT_OBI, VX_SEND_RSP}       state_vx_t;
    typedef enum logic [1:0] {IDLE_OBI, OBI_SEND_REQ, OBI_WAIT_RSP} state_obi_t;

    state_vx_t [NUM_REQS-1:0] curr_state_vx;
    state_vx_t [NUM_REQS-1:0] next_state_vx;

    state_obi_t [NUM_REQS-1:0] curr_state_obi;
    state_obi_t [NUM_REQS-1:0] next_state_obi;

    logic [NUM_REQS-1:0]                    curr_vx_valid;
    logic [NUM_REQS-1:0]                    curr_vx_rw;
    logic [NUM_REQS-1:0][3:0]               curr_vx_byteen;
    logic [NUM_REQS-1:0][31:0]              curr_vx_addr;
    logic [NUM_REQS-1:0][31:0]              curr_vx_data;
    logic [NUM_REQS-1:0][TAG_WIDTH_BIT-1:0] curr_vx_tag;

    logic [NUM_REQS-1:0]                    next_vx_valid;
    logic [NUM_REQS-1:0]                    next_vx_rw;
    logic [NUM_REQS-1:0][3:0]               next_vx_byteen;
    logic [NUM_REQS-1:0][31:0]              next_vx_addr;
    logic [NUM_REQS-1:0][31:0]              next_vx_data;
    logic [NUM_REQS-1:0][TAG_WIDTH_BIT-1:0] next_vx_tag;

    logic [NUM_REQS-1:0]       curr_obi_rvalid;
    logic [NUM_REQS-1:0][31:0] curr_obi_rdata;

    logic [NUM_REQS-1:0]       next_obi_rvalid;
    logic [NUM_REQS-1:0][31:0] next_obi_rdata;

    logic                start_obi;
    logic [NUM_REQS-1:0] store_obi;
    logic                done_obi;

    logic store_vx;

    logic [NUM_REQS-1:0] vx_dcache_req_ready;
    logic [NUM_REQS-1:0] vx_dcache_rsp_valid;
    logic                vx_dcache_rsp_tmask;

    /*
    * Store input VX request
    */
    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            curr_vx_valid  <= '0;
            curr_vx_rw     <= '0;
            curr_vx_byteen <= '0;
            curr_vx_addr   <= '0;
            curr_vx_data   <= '0;
            curr_vx_tag    <= '0;
        end
        else begin
            curr_vx_valid  <= next_vx_valid;
            curr_vx_rw     <= next_vx_rw;
            curr_vx_byteen <= next_vx_byteen;
            curr_vx_addr   <= next_vx_addr;
            curr_vx_data   <= next_vx_data;
            curr_vx_tag    <= next_vx_tag;
        end
    end

    assign next_vx_valid  = store_vx ? vx_dcache_req.valid         : curr_vx_valid;
    assign next_vx_rw     = store_vx ? vx_dcache_req.rw            : curr_vx_rw;
    assign next_vx_byteen = store_vx ? vx_dcache_req.byteen        : curr_vx_byteen;
    assign next_vx_addr   = store_vx ? {vx_dcache_req.addr, 2'b00} : curr_vx_addr;
    assign next_vx_data   = store_vx ? vx_dcache_req.data          : curr_vx_data;
    assign next_vx_tag    = store_vx ? vx_dcache_req.tag           : curr_vx_tag;

    genvar i;
    generate
        for (i=0; i<NUM_REQS; i++) begin
            assign obi_req[i].we    = curr_vx_rw[i];
            assign obi_req[i].be    = curr_vx_byteen[i];
            assign obi_req[i].addr  = curr_vx_addr[i];
            assign obi_req[i].wdata = curr_vx_data[i];
        end
    endgenerate

    assign vx_dcache_rsp.tag   = curr_vx_tag[0];
    assign vx_dcache_rsp_tmask = curr_vx_valid&(~curr_vx_rw);
    assign vx_dcache_rsp.tmask = vx_dcache_rsp_tmask;

    /*
    * Store input OBI response
    */
    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            curr_obi_rvalid <= '0;
            curr_obi_rdata  <= '0;
        end
        else begin
            curr_obi_rvalid <= next_obi_rvalid;
            curr_obi_rdata  <= next_obi_rdata;
        end
    end

    generate
        for (i=0; i<NUM_REQS; i++) begin
            assign next_obi_rvalid[i] = store_obi[i] ? obi_rsp[i].rvalid : curr_obi_rvalid[i];
            assign next_obi_rdata[i]  = store_obi[i] ? obi_rsp[i].rdata  : curr_obi_rdata[i];
        end
    endgenerate

    assign vx_dcache_rsp.data = curr_obi_rdata;

    assign done_obi = &(~(curr_vx_valid^curr_obi_rvalid));

    /*
    * Send ready and valid signals
    */
    assign vx_dcache_req.ready = vx_dcache_req_ready;
    assign vx_dcache_rsp.valid = vx_dcache_rsp_valid;

    /*
    * FSM VX
    */
    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni)
            curr_state_vx <= IDLE_VX;
        else
            curr_state_vx <= next_state_vx;
    end

    always_comb begin
        next_state_vx       = curr_state_vx;
        store_vx            = 1'b0;
        vx_dcache_req_ready = '0;
        vx_dcache_rsp_valid = 1'b0;
        case (curr_state_vx)
            IDLE_VX: begin
                if (|vx_dcache_req.valid) begin
                    store_vx            = 1'b1;
                    vx_dcache_req_ready = vx_dcache_req.valid;
                    next_state_vx       = WAIT_OBI;
                end
                else begin
                    next_state_vx = IDLE_VX;
                end
            end
            WAIT_OBI: begin
                if (done_obi) begin
                    if (|vx_dcache_rsp_tmask) begin
                        next_state_vx = VX_SEND_RSP;
                    end
                    else begin
                        next_state_vx = IDLE_VX;
                    end
                end
                else begin
                    next_state_vx = WAIT_OBI;
                end
            end
            VX_SEND_RSP: begin
                vx_dcache_rsp_valid = 1'b1;
                if (vx_dcache_rsp.ready) begin
                    next_state_vx = IDLE_VX;
                end
                else begin
                    next_state_vx = VX_SEND_RSP;
                end
            end
            default: begin
                next_state_vx = IDLE_VX;
            end
        endcase
    end

    /*
    * FSM OBI
    */
    generate
        for (i=0; i<NUM_REQS; i++) begin
            always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
                if (!rst_ni)
                    curr_state_obi[i] <= IDLE_OBI;
                else
                    curr_state_obi[i] <= next_state_obi[i];
            end

            always_comb begin
                next_state_obi[i] = curr_state_obi[i];
                obi_req[i].req    = 1'b0;
                store_obi[i]      = 1'b0;
                case (curr_state_obi[i])
                    IDLE_OBI: begin
                        if (start_obi & vx_dcache_req.valid[i]) begin
                            next_state_obi[i] = OBI_SEND_REQ;
                            store_obi[i]      = 1'b1; // UPDATE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        end
                        else begin
                            next_state_obi[i] = IDLE_OBI;
                        end
                    end
                    OBI_SEND_REQ: begin
                        obi_req[i].req = 1'b1;
                        if (obi_req[i].gnt) begin
                            next_state_obi[i] = OBI_WAIT_RSP;
                        end
                        else begin
                            next_state_obi[i] = OBI_SEND_REQ;
                        end
                    end
                    OBI_WAIT_RSP: begin
                        if (obi_rsp[i].rvalid) begin
                            store_obi[i]  = 1'b1;
                            next_state_obi[i] = IDLE_OBI;
                        end
                        else begin
                            next_state_obi[i] = OBI_WAIT_RSP;
                        end
                    end
                    default: begin
                        next_state_obi[i] = IDLE_OBI;
                    end
                endcase
            end
        end
    endgenerate

    assign start_obi = store_vx;

endmodule
