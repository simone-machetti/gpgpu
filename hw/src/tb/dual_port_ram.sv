// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

module dual_port_ram #(
    parameter MEM_SIZE_WORD = 32768
)(
    input logic clk_i,
    input logic rst_ni,

    obi_req_if.slave  instr_mem_req,
    obi_rsp_if.master instr_mem_rsp,

    obi_req_if.slave  data_mem_req,
    obi_rsp_if.master data_mem_rsp
);

    logic [31:0] mem_array [0:MEM_SIZE_WORD-1];

    typedef enum logic [1:0] {IDLE, READ, WRITE} state_t;

    state_t instr_curr_state;
    state_t instr_next_state;

    logic [29:0] instr_addr;

    state_t data_curr_state;
    state_t data_next_state;

    logic [3:0]  data_be;
    logic [29:0] data_addr;
    logic [31:0] data_wdata;

    /*
    * Instruction FSM
    */
    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            instr_addr <= '0;
        end
        else begin
            instr_addr <= instr_mem_req.addr[31:2];
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            instr_curr_state <= IDLE;
        end
        else begin
            instr_curr_state <= instr_next_state;
        end
    end

    always_comb begin
        instr_next_state     = instr_curr_state;
        instr_mem_req.gnt    = 1'b0;
        instr_mem_rsp.rvalid = 1'b0;
        instr_mem_rsp.rdata  = 32'd0;
        case(instr_curr_state)
            IDLE: begin
                if (instr_mem_req.req) begin
                    instr_mem_req.gnt = 1'b1;
                    if (instr_mem_req.we)
                        instr_next_state = IDLE;
                    else
                        instr_next_state = READ;
                end
                else begin
                    instr_next_state = IDLE;
                end
            end
            READ: begin
                instr_mem_rsp.rvalid = 1'b1;
                instr_mem_rsp.rdata  = mem_array[instr_addr];
                instr_next_state     = IDLE;
            end
            default: begin
                instr_next_state = IDLE;
            end
        endcase
    end

    /*
    * Data FSM
    */
    always_ff @(posedge(clk_i) or negedge(rst_ni)) begin
        if (!rst_ni) begin
            data_be    <= '0;
            data_addr  <= '0;
            data_wdata <= '0;
        end
        else begin
            data_be    <= data_mem_req.be;
            data_addr  <= data_mem_req.addr[31:2];
            data_wdata <= data_mem_req.wdata;
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            data_curr_state <= IDLE;
        end
        else begin
            data_curr_state <= data_next_state;
        end
    end

    always_comb begin
        data_next_state     = data_curr_state;
        data_mem_req.gnt    = 1'b0;
        data_mem_rsp.rvalid = 1'b0;
        data_mem_rsp.rdata  = 32'd0;
        case(data_curr_state)
            IDLE: begin
                if (data_mem_req.req) begin
                    if (data_mem_req.we) begin
                        data_mem_req.gnt = 1'b1;
                        data_next_state  = WRITE;
                    end
                    else begin
                        data_mem_req.gnt = 1'b1;
                        data_next_state  = READ;
                    end
                end
                else begin
                    data_next_state = IDLE;
                end
            end
            READ: begin
                data_mem_rsp.rvalid = 1'b1;
                data_mem_rsp.rdata  = mem_array[data_addr];
                data_next_state     = IDLE;
            end
            WRITE: begin
                data_mem_rsp.rvalid             = 1'b1;
                if (data_be[0])
                    mem_array[data_addr][7:0]   = data_wdata[7:0];
                if (data_be[1])
                    mem_array[data_addr][15:8]  = data_wdata[15:8];
                if (data_be[2])
                    mem_array[data_addr][23:16] = data_wdata[23:16];
                if (data_be[3])
                    mem_array[data_addr][31:24] = data_wdata[31:24];
                data_next_state                 = IDLE;
            end
            default: begin
                data_next_state = IDLE;
            end
        endcase
    end

endmodule
