// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module controller_scratchpad
(
    input logic clk_i,
    input logic rst_ni,

    obi_req_if.slave  regs_req,
    obi_rsp_if.master regs_rsp,

    output logic clk_core_en_o,
    output logic rst_n_core_o,

    dma_ctrl_if.master dma_instr_ctrl,
    dma_ctrl_if.master dma_data_ctrl
);

    /*
    * REGISTERS:
    *
    * - regs[0][0]    : start core - active high (default: 0)
    * - regs[1][0]    : reset core - active low  (default: 0)
    * - regs[2]       : unused
    * - regs[3][31:0] : instruction dma length
    * - regs[4][31:0] : instruction dma source address
    * - regs[5][31:0] : instruction dma destination address
    * - regs[6][0]    : instruction dma direction (0: external to internal - 1: internal to external)
    * - regs[7][0]    : instruction dma start - active high (default: 0)
    * - regs[8][0]    : instruction dma done
    * - regs[9]       : data dma length
    * - regs[10]      : data dma source address
    * - regs[11]      : data dma destination address
    * - regs[12][0]   : data dma direction (0: external to internal - 1: internal to external)
    * - regs[13][0]   : data dma start - active high (default: 0)
    * - regs[14][0]   : data dma done
    * - regs[15]      : unused
    *
    */

    logic [31:0] curr_regs [0:15];
    logic [31:0] next_regs [0:15];

    typedef enum logic [1:0] {IDLE, READ, WRITE} state_t;

    state_t curr_state;
    state_t next_state;

    logic [3:0]  be;
    logic [3:0]  addr;
    logic [31:0] wdata;

    assign clk_core_en_o = curr_regs[0][0];
    assign rst_n_core_o  = curr_regs[1][0];

    assign dma_instr_ctrl.len   = curr_regs[3];
    assign dma_instr_ctrl.src   = curr_regs[4];
    assign dma_instr_ctrl.dst   = curr_regs[5];
    assign dma_instr_ctrl.dir   = curr_regs[6][0];
    assign dma_instr_ctrl.start = curr_regs[7][0];

    assign dma_data_ctrl.len   = curr_regs[9];
    assign dma_data_ctrl.src   = curr_regs[10];
    assign dma_data_ctrl.dst   = curr_regs[11];
    assign dma_data_ctrl.dir   = curr_regs[12][0];
    assign dma_data_ctrl.start = curr_regs[13][0];

    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            for (int i=0; i<16; i++) begin
                curr_regs[i] <= 32'h00000000;
            end
        end
        else begin
            curr_regs <= next_regs;
        end
    end

    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            be    <= '0;
            addr  <= '0;
            wdata <= '0;
        end
        else begin
            be    <= regs_req.be;
            addr  <= regs_req.addr[5:2];
            wdata <= regs_req.wdata;
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
        next_state      = curr_state;
        regs_req.gnt    = 1'b0;
        regs_rsp.rvalid = 1'b0;
        regs_rsp.rdata  = 32'd0;
        for (int i=0; i<16; i++) begin
            if ((i != 32'd8) && (i != 32'd14)) begin
                next_regs[i] = curr_regs[i];
            end
        end
        next_regs[8]  = {31'd0, dma_instr_ctrl.done};
        next_regs[14] = {31'd0, dma_data_ctrl.done};
        case(curr_state)
            IDLE: begin
                if (regs_req.req) begin
                    if (regs_req.we) begin
                        regs_req.gnt = 1'b1;
                        next_state   = WRITE;
                    end
                    else begin
                        regs_req.gnt = 1'b1;
                        next_state   = READ;
                    end
                end
                else begin
                    next_state = IDLE;
                end
            end
            READ: begin
                regs_rsp.rvalid = 1'b1;
                regs_rsp.rdata  = curr_regs[addr];
                next_state      = IDLE;
            end
            WRITE: begin
                regs_rsp.rvalid = 1'b1;
                if ((addr != 32'd8) && (addr != 32'd14)) begin
                    if (be[0])
                        next_regs[addr][7:0]   = wdata[7:0];
                    if (be[1])
                        next_regs[addr][15:8]  = wdata[15:8];
                    if (be[2])
                        next_regs[addr][23:16] = wdata[23:16];
                    if (be[3])
                        next_regs[addr][31:24] = wdata[31:24];
                end
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
