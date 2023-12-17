// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

module ram # (
  parameter RAM_ADDR_BITS                 = 32
) (
  // Clock and reset
  input  logic                            clk_i,
  input  logic                            rst_i,

  // Memory request
  input  logic                            mem_req_valid_i,
  input  logic                            mem_req_rw_i,
  input  logic [`VX_MEM_BYTEEN_WIDTH-1:0] mem_req_byteen_i,
  input  logic [RAM_ADDR_BITS-1:0]        mem_req_addr_i,
  input  logic [`VX_MEM_DATA_WIDTH-1:0]   mem_req_data_i,
  input  logic [`VX_MEM_TAG_WIDTH-1:0]    mem_req_tag_i,
  output logic                            mem_req_ready_o,

  // Memory response
  output logic                            mem_rsp_valid_o,
  output logic [`VX_MEM_DATA_WIDTH-1:0]   mem_rsp_data_o,
  output logic [`VX_MEM_TAG_WIDTH-1:0]    mem_rsp_tag_o,
  input  logic                            mem_rsp_ready_i
);

  logic [`VX_MEM_DATA_WIDTH-1:0] mem_array [0:(1<<RAM_ADDR_BITS)-1];

  // Declare states
  typedef enum logic [1:0] {
    IDLE,
    READ1,
    READ2,
    WRITE1
  } state;

  state currstate, nextstate;

  logic store_req;

  // Input signals
  logic [12-1:0]                 mem_req_addr;
  logic [`VX_MEM_TAG_WIDTH-1:0]  mem_req_tag;

  // Output signals
  logic                          mem_req_ready;
  logic                          mem_rsp_valid;
  logic [`VX_MEM_DATA_WIDTH-1:0] mem_rsp_data;
  logic [`VX_MEM_TAG_WIDTH-1:0]  mem_rsp_tag;

  // Sequential logic
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      currstate <= IDLE;
    end else begin
      currstate <= nextstate;
    end
  end

  // Request registers
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      currstate <= IDLE;
    end else begin
      if (store_req) begin
        mem_req_addr <= mem_req_addr_i;
        mem_req_tag  <= mem_req_tag_i;
      end
    end
  end

  // Combinational logic
  always_comb begin
    nextstate = currstate;
    store_req = 1'b0;
    mem_req_ready = '0;
    mem_rsp_valid = '0;
    mem_rsp_data  = '0;
    mem_rsp_tag   = '0;

    case(currstate)
      IDLE: begin
        if (mem_req_valid_i) begin
          if (mem_req_rw_i) begin
            nextstate = WRITE1;
          end else begin
            nextstate = READ1;
          end
        end else begin
          nextstate = IDLE;
        end
      end

      READ1: begin
        mem_req_ready = 1'b1;
        store_req = 1'b1;
        nextstate = READ2;
      end

      READ2: begin
        if (mem_rsp_ready_i) begin
          mem_rsp_data  = mem_array[mem_req_addr];
          mem_rsp_tag   = mem_req_tag;
          mem_rsp_valid = 1'b1;
          nextstate     = IDLE;
        end else begin
          nextstate = READ2;
        end
      end

      WRITE1: begin
        mem_req_ready = 1'b1;
        for(int i=0; i<64; i++) begin
          if (mem_req_byteen_i & (64'h1 << i))
            mem_array[mem_req_addr_i][i*8+:8] = mem_req_data_i[i*8+:8];
        end
        nextstate = IDLE;
      end

      default: begin
        // do nothing
      end
    endcase
  end

  // Output assignment
  assign mem_req_ready_o = mem_req_ready;
  assign mem_rsp_valid_o = mem_rsp_valid;
  assign mem_rsp_data_o  = mem_rsp_data;
  assign mem_rsp_tag_o   = mem_rsp_tag;

endmodule
