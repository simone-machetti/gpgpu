// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module dma
(
    input logic clk_i,
    input logic rst_ni,

    obi_req_if.master ext_instr_req,
    obi_rsp_if.slave  ext_instr_rsp,

    obi_req_if.master ext_data_req,
    obi_rsp_if.slave  ext_data_rsp,

    obi_req_if.master int_instr_req,
    obi_rsp_if.slave  int_instr_rsp,

    obi_req_if.master int_data_req,
    obi_rsp_if.slave  int_data_rsp,

    dma_ctrl_if.slave instr_ctrl,
    dma_ctrl_if.slave data_ctrl
);

    /*
    * Instruction signals
    */
    typedef enum logic [2:0] {INSTR_IDLE, INSTR_READ_OBI_SEND_REQ, INSTR_READ_OBI_WAIT_RSP, INSTR_WRITE_OBI_SEND_REQ, INSTR_WRITE_OBI_WAIT_RSP, INSTR_WAIT_START_TO_ZERO} instr_state_t;

    instr_state_t curr_state_instr;
    instr_state_t next_state_instr;

    logic [31:0] curr_instr_ctrl_len;
    logic [31:0] curr_instr_ctrl_src;
    logic [31:0] curr_instr_ctrl_dst;
    logic        curr_instr_ctrl_dir;

    logic [31:0] next_instr_ctrl_len;
    logic [31:0] next_instr_ctrl_src;
    logic [31:0] next_instr_ctrl_dst;
    logic        next_instr_ctrl_dir;

    logic [31:0] curr_instr_rdata;
    logic [31:0] next_instr_rdata;

    logic load_instr_ctrl;
    logic count_instr_ctrl;

    logic load_instr_rdata;

    /*
    * Data signals
    */
    typedef enum logic [2:0] {DATA_IDLE, DATA_READ_OBI_SEND_REQ, DATA_READ_OBI_WAIT_RSP, DATA_WRITE_OBI_SEND_REQ, DATA_WRITE_OBI_WAIT_RSP, DATA_WAIT_START_TO_ZERO} data_state_t;

    data_state_t curr_state_data;
    data_state_t next_state_data;

    logic [31:0] curr_data_ctrl_len;
    logic [31:0] curr_data_ctrl_src;
    logic [31:0] curr_data_ctrl_dst;
    logic        curr_data_ctrl_dir;

    logic [31:0] next_data_ctrl_len;
    logic [31:0] next_data_ctrl_src;
    logic [31:0] next_data_ctrl_dst;
    logic        next_data_ctrl_dir;

    logic [31:0] curr_data_rdata;
    logic [31:0] next_data_rdata;

    logic load_data_ctrl;
    logic count_data_ctrl;

    logic load_data_rdata;

    /*
    * Instruction channel
    */
    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            curr_instr_ctrl_len <= '0;
            curr_instr_ctrl_src <= '0;
            curr_instr_ctrl_dst <= '0;
            curr_instr_ctrl_dir <= '0;
        end
        else begin
            curr_instr_ctrl_len <= next_instr_ctrl_len;
            curr_instr_ctrl_src <= next_instr_ctrl_src;
            curr_instr_ctrl_dst <= next_instr_ctrl_dst;
            curr_instr_ctrl_dir <= next_instr_ctrl_dir;
        end
    end

    assign next_instr_ctrl_len = load_instr_ctrl ? instr_ctrl.len : count_instr_ctrl ? curr_instr_ctrl_len-32'd4 : curr_instr_ctrl_len;
    assign next_instr_ctrl_src = load_instr_ctrl ? instr_ctrl.src : count_instr_ctrl ? curr_instr_ctrl_src+32'd4 : curr_instr_ctrl_src;
    assign next_instr_ctrl_dst = load_instr_ctrl ? instr_ctrl.dst : count_instr_ctrl ? curr_instr_ctrl_dst+32'd4 : curr_instr_ctrl_dst;
    assign next_instr_ctrl_dir = load_instr_ctrl ? instr_ctrl.dir : curr_instr_ctrl_dir;

    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            curr_instr_rdata <= '0;
        end
        else begin
            curr_instr_rdata <= next_instr_rdata;
        end
    end

    always_comb begin
        if (curr_instr_ctrl_dir) begin
            int_instr_req.we    = 1'b0;
            int_instr_req.be    = 4'b1111;
            int_instr_req.addr  = curr_instr_ctrl_src;
            int_instr_req.wdata = 32'd0;

            if (load_instr_rdata)
                next_instr_rdata = int_instr_rsp.rdata;
            else
                next_instr_rdata = curr_instr_rdata;

            ext_instr_req.we    = 1'b1;
            ext_instr_req.be    = 4'b1111;
            ext_instr_req.addr  = curr_instr_ctrl_dst;
            ext_instr_req.wdata = curr_instr_rdata;
        end
        else begin
            ext_instr_req.we    = 1'b0;
            ext_instr_req.be    = 4'b1111;
            ext_instr_req.addr  = curr_instr_ctrl_src;
            ext_instr_req.wdata = 32'd0;

            if (load_instr_rdata)
                next_instr_rdata = ext_instr_rsp.rdata;
            else
                next_instr_rdata = curr_instr_rdata;

            int_instr_req.we    = 1'b1;
            int_instr_req.be    = 4'b1111;
            int_instr_req.addr  = curr_instr_ctrl_dst;
            int_instr_req.wdata = curr_instr_rdata;
        end

    end

    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            curr_state_instr <= INSTR_IDLE;
        end
        else begin
            curr_state_instr <= next_state_instr;
        end
    end

    always_comb begin

        next_state_instr  = curr_state_instr;
        load_instr_ctrl   = 1'b0;
        int_instr_req.req = 1'b0;
        ext_instr_req.req = 1'b0;
        load_instr_rdata  = 1'b0;
        count_instr_ctrl  = 1'b0;
        instr_ctrl.done   = 1'b0;

        case (curr_state_instr)

            INSTR_IDLE: begin
                if (instr_ctrl.start) begin
                    load_instr_ctrl  = 1'b1;
                    next_state_instr = INSTR_READ_OBI_SEND_REQ;
                end
                else begin
                    next_state_instr = INSTR_IDLE;
                end
            end

            INSTR_READ_OBI_SEND_REQ: begin
                if (curr_instr_ctrl_len == 32'd0) begin
                    next_state_instr = INSTR_WAIT_START_TO_ZERO;
                end
                else begin
                    if (curr_instr_ctrl_dir) begin
                        int_instr_req.req = 1'b1;
                        if (int_instr_req.gnt) begin
                            next_state_instr = INSTR_READ_OBI_WAIT_RSP;
                        end
                        else begin
                            next_state_instr = INSTR_READ_OBI_SEND_REQ;
                        end
                    end
                    else begin
                        ext_instr_req.req = 1'b1;
                        if (ext_instr_req.gnt) begin
                            next_state_instr = INSTR_READ_OBI_WAIT_RSP;
                        end
                        else begin
                            next_state_instr = INSTR_READ_OBI_SEND_REQ;
                        end
                    end
                end
            end

            INSTR_READ_OBI_WAIT_RSP: begin
                if (curr_instr_ctrl_dir) begin
                    if (int_instr_rsp.rvalid) begin
                        load_instr_rdata = 1'b1;
                        next_state_instr = INSTR_WRITE_OBI_SEND_REQ;
                    end
                    else begin
                        next_state_instr = INSTR_READ_OBI_WAIT_RSP;
                    end
                end
                else begin
                    if (ext_instr_rsp.rvalid) begin
                        load_instr_rdata = 1'b1;
                        next_state_instr = INSTR_WRITE_OBI_SEND_REQ;
                    end
                    else begin
                        next_state_instr = INSTR_READ_OBI_WAIT_RSP;
                    end
                end
            end

            INSTR_WRITE_OBI_SEND_REQ: begin
                if (curr_instr_ctrl_dir) begin
                    ext_instr_req.req = 1'b1;
                    if (ext_instr_req.gnt) begin
                        next_state_instr = INSTR_WRITE_OBI_WAIT_RSP;
                    end
                    else begin
                        next_state_instr = INSTR_WRITE_OBI_SEND_REQ;
                    end
                end
                else begin
                    int_instr_req.req = 1'b1;
                    if (int_instr_req.gnt) begin
                        next_state_instr = INSTR_WRITE_OBI_WAIT_RSP;
                    end
                    else begin
                        next_state_instr = INSTR_WRITE_OBI_SEND_REQ;
                    end
                end
            end

            INSTR_WRITE_OBI_WAIT_RSP: begin
                if (curr_instr_ctrl_dir) begin
                    if (ext_instr_rsp.rvalid) begin
                        next_state_instr = INSTR_READ_OBI_SEND_REQ;
                        count_instr_ctrl = 1'b1;
                    end
                    else begin
                        next_state_instr = INSTR_WRITE_OBI_WAIT_RSP;
                    end
                end
                else begin
                    if (int_instr_rsp.rvalid) begin
                        next_state_instr = INSTR_READ_OBI_SEND_REQ;
                        count_instr_ctrl = 1'b1;
                    end
                    else begin
                        next_state_instr = INSTR_WRITE_OBI_WAIT_RSP;
                    end
                end
            end

            INSTR_WAIT_START_TO_ZERO: begin
                instr_ctrl.done = 1'b1;
                if (instr_ctrl.start) begin
                    next_state_instr = INSTR_WAIT_START_TO_ZERO;
                end
                else begin
                    next_state_instr = INSTR_IDLE;
                end
            end

            default: begin
                next_state_instr = INSTR_IDLE;
            end

        endcase
    end

    /*
    * Data channel
    */
    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            curr_data_ctrl_len <= '0;
            curr_data_ctrl_src <= '0;
            curr_data_ctrl_dst <= '0;
            curr_data_ctrl_dir <= '0;
        end
        else begin
            curr_data_ctrl_len <= next_data_ctrl_len;
            curr_data_ctrl_src <= next_data_ctrl_src;
            curr_data_ctrl_dst <= next_data_ctrl_dst;
            curr_data_ctrl_dir <= next_data_ctrl_dir;
        end
    end

    assign next_data_ctrl_len = load_data_ctrl ? data_ctrl.len : count_data_ctrl ? curr_data_ctrl_len-32'd4 : curr_data_ctrl_len;
    assign next_data_ctrl_src = load_data_ctrl ? data_ctrl.src : count_data_ctrl ? curr_data_ctrl_src+32'd4 : curr_data_ctrl_src;
    assign next_data_ctrl_dst = load_data_ctrl ? data_ctrl.dst : count_data_ctrl ? curr_data_ctrl_dst+32'd4 : curr_data_ctrl_dst;
    assign next_data_ctrl_dir = load_data_ctrl ? data_ctrl.dir : curr_data_ctrl_dir;

    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            curr_data_rdata <= '0;
        end
        else begin
            curr_data_rdata <= next_data_rdata;
        end
    end

    always_comb begin
        if (curr_data_ctrl_dir) begin
            int_data_req.we    = 1'b0;
            int_data_req.be    = 4'b1111;
            int_data_req.addr  = curr_data_ctrl_src;
            int_data_req.wdata = 32'd0;

            if (load_data_rdata)
                next_data_rdata = int_data_rsp.rdata;
            else
                next_data_rdata = curr_data_rdata;

            ext_data_req.we    = 1'b1;
            ext_data_req.be    = 4'b1111;
            ext_data_req.addr  = curr_data_ctrl_dst;
            ext_data_req.wdata = curr_data_rdata;
        end
        else begin
            ext_data_req.we    = 1'b0;
            ext_data_req.be    = 4'b1111;
            ext_data_req.addr  = curr_data_ctrl_src;
            ext_data_req.wdata = 32'd0;

            if (load_data_rdata)
                next_data_rdata = ext_data_rsp.rdata;
            else
                next_data_rdata = curr_data_rdata;

            int_data_req.we    = 1'b1;
            int_data_req.be    = 4'b1111;
            int_data_req.addr  = curr_data_ctrl_dst;
            int_data_req.wdata = curr_data_rdata;
        end

    end

    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            curr_state_data <= DATA_IDLE;
        end
        else begin
            curr_state_data <= next_state_data;
        end
    end

    always_comb begin

        next_state_data  = curr_state_data;
        load_data_ctrl   = 1'b0;
        int_data_req.req = 1'b0;
        ext_data_req.req = 1'b0;
        load_data_rdata  = 1'b0;
        count_data_ctrl  = 1'b0;
        data_ctrl.done   = 1'b0;

        case (curr_state_data)

            DATA_IDLE: begin
                if (data_ctrl.start) begin
                    load_data_ctrl  = 1'b1;
                    next_state_data = DATA_READ_OBI_SEND_REQ;
                end
                else begin
                    next_state_data = DATA_IDLE;
                end
            end

            DATA_READ_OBI_SEND_REQ: begin
                if (curr_data_ctrl_len == 32'd0) begin
                    next_state_data = DATA_WAIT_START_TO_ZERO;
                end
                else begin
                    if (curr_data_ctrl_dir) begin
                        int_data_req.req = 1'b1;
                        if (int_data_req.gnt) begin
                            next_state_data = DATA_READ_OBI_WAIT_RSP;
                        end
                        else begin
                            next_state_data = DATA_READ_OBI_SEND_REQ;
                        end
                    end
                    else begin
                        ext_data_req.req = 1'b1;
                        if (ext_data_req.gnt) begin
                            next_state_data = DATA_READ_OBI_WAIT_RSP;
                        end
                        else begin
                            next_state_data = DATA_READ_OBI_SEND_REQ;
                        end
                    end
                end
            end

            DATA_READ_OBI_WAIT_RSP: begin
                if (curr_data_ctrl_dir) begin
                    if (int_data_rsp.rvalid) begin
                        load_data_rdata = 1'b1;
                        next_state_data = DATA_WRITE_OBI_SEND_REQ;
                    end
                    else begin
                        next_state_data = DATA_READ_OBI_WAIT_RSP;
                    end
                end
                else begin
                    if (ext_data_rsp.rvalid) begin
                        load_data_rdata = 1'b1;
                        next_state_data = DATA_WRITE_OBI_SEND_REQ;
                    end
                    else begin
                        next_state_data = DATA_READ_OBI_WAIT_RSP;
                    end
                end
            end

            DATA_WRITE_OBI_SEND_REQ: begin
                if (curr_data_ctrl_dir) begin
                    ext_data_req.req = 1'b1;
                    if (ext_data_req.gnt) begin
                        next_state_data = DATA_WRITE_OBI_WAIT_RSP;
                    end
                    else begin
                        next_state_data = DATA_WRITE_OBI_SEND_REQ;
                    end
                end
                else begin
                    int_data_req.req = 1'b1;
                    if (int_data_req.gnt) begin
                        next_state_data = DATA_WRITE_OBI_WAIT_RSP;
                    end
                    else begin
                        next_state_data = DATA_WRITE_OBI_SEND_REQ;
                    end
                end
            end

            DATA_WRITE_OBI_WAIT_RSP: begin
                if (curr_data_ctrl_dir) begin
                    if (ext_data_rsp.rvalid) begin
                        next_state_data = DATA_READ_OBI_SEND_REQ;
                        count_data_ctrl = 1'b1;
                    end
                    else begin
                        next_state_data = DATA_WRITE_OBI_WAIT_RSP;
                    end
                end
                else begin
                    if (int_data_rsp.rvalid) begin
                        next_state_data = DATA_READ_OBI_SEND_REQ;
                        count_data_ctrl = 1'b1;
                    end
                    else begin
                        next_state_data = DATA_WRITE_OBI_WAIT_RSP;
                    end
                end
            end

            DATA_WAIT_START_TO_ZERO: begin
                data_ctrl.done = 1'b1;
                if (data_ctrl.start) begin
                    next_state_data = DATA_WAIT_START_TO_ZERO;
                end
                else begin
                    next_state_data = DATA_IDLE;
                end
            end

            default: begin
                next_state_data = DATA_IDLE;
            end

        endcase
    end

endmodule
