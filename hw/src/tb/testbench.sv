// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`include "VX_define.vh"

`define RAM_SIZE       32 // KB
`define RAM_BLOCK_SIZE 64 // B

`define RAM_ADDR_BITS  $clog2((`RAM_SIZE*1024)/`RAM_BLOCK_SIZE)
`define RAM_ARGS_ADDR  ((`RAM_SIZE-1)*1024)/`RAM_BLOCK_SIZE

`define IN_FILE  "$GPGPU_HOME/hw/imp/sim/input/kernel.mem"
`define OUT_FILE "$GPGPU_HOME/hw/imp/sim/output/output.mem"

task init_ram;
begin
  int i;

  // Init RAM to zero
  for (i=0; i<(1<<`RAM_ADDR_BITS); i++) begin
    testbench.ram_i.mem_array[i] = 0;
  end

  // Init RAM from file
  $readmemh(`IN_FILE, testbench.ram_i.mem_array);
end
endtask

task dump_ram;
begin
  int fd;
  int i;

  // Open output file
  fd = $fopen(`OUT_FILE, "w");

  // Read RAM
  for (i=0; i<(1<<`RAM_ADDR_BITS); i++) begin
    $fdisplay(fd, "%X", testbench.ram_i.mem_array[i]);
  end
end
endtask

task init_vcd;
begin
  // Create VCD file
  $dumpfile("output.vcd");
end
endtask

task start_vcd;
begin
  // Start dump to VCD file
  $dumpvars(0, testbench);
end
endtask

task stop_vcd;
begin
  // Stop dump to VCD file
  $dumpoff;
end
endtask

module testbench (
);
  // Clock and reset
  logic                            clk;
  logic                            rst;

  // Memory request
  logic                            mem_req_valid;
  logic                            mem_req_rw;
  logic [`VX_MEM_BYTEEN_WIDTH-1:0] mem_req_byteen;
  logic [`VX_MEM_ADDR_WIDTH-1:0]   mem_req_addr;
  logic [`VX_MEM_DATA_WIDTH-1:0]   mem_req_data;
  logic [`VX_MEM_TAG_WIDTH-1:0]    mem_req_tag;
  logic                            mem_req_ready;

  // Memory response
  logic                            mem_rsp_valid;
  logic [`VX_MEM_DATA_WIDTH-1:0]   mem_rsp_data;
  logic [`VX_MEM_TAG_WIDTH-1:0]    mem_rsp_tag;
  logic                            mem_rsp_ready;

  Vortex vortex (
    .clk            (clk),
    .reset          (rst),

    .mem_req_valid  (mem_req_valid),
    .mem_req_rw     (mem_req_rw),
    .mem_req_byteen (mem_req_byteen),
    .mem_req_addr   (mem_req_addr),
    .mem_req_data   (mem_req_data),
    .mem_req_tag    (mem_req_tag),
    .mem_req_ready  (mem_req_ready),

    .mem_rsp_valid  (mem_rsp_valid),
    .mem_rsp_data   (mem_rsp_data),
    .mem_rsp_tag    (mem_rsp_tag),
    .mem_rsp_ready  (mem_rsp_ready),

    .busy           ()
  );

  ram # (
    .RAM_ADDR_BITS    (`RAM_ADDR_BITS)
  ) ram_i (
    .clk_i            (clk),
    .rst_i            (rst),

    .mem_req_valid_i  (mem_req_valid),
    .mem_req_rw_i     (mem_req_rw),
    .mem_req_byteen_i (mem_req_byteen),
    .mem_req_addr_i   (mem_req_addr[`RAM_ADDR_BITS-1:0]),
    .mem_req_data_i   (mem_req_data),
    .mem_req_tag_i    (mem_req_tag),
    .mem_req_ready_o  (mem_req_ready),

    .mem_rsp_valid_o  (mem_rsp_valid),
    .mem_rsp_data_o   (mem_rsp_data),
    .mem_rsp_tag_o    (mem_rsp_tag),
    .mem_rsp_ready_i  (mem_rsp_ready)
  );

  // Clock freq and period
  real clk_freq   = 100; // MHz
  real clk_period = 1000/clk_freq;

  initial begin
    // Reset system
    rst = 1'b1;

    // Create VCD file
    init_vcd;

    // Init RAM from file
    init_ram;

    // Start dump to VCD file
    start_vcd;

    // Release reset
    #(clk_period*100);
    #(clk_period/4);
    rst = 1'b0;
  end

  always begin
    // Generate clock
    clk = 1'b0;
    #(clk_period/2);
    clk = 1'b1;
    #(clk_period/2);

    // Check done
    if(testbench.ram_i.mem_array[`RAM_ARGS_ADDR][31:0] == 1) begin

      // Stop dump to VCD file
      stop_vcd;

      // Dump RAM tp file
      dump_ram;

      // End simulation
      $stop;
    end
  end

endmodule
