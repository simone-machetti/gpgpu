// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`define INSTR_MEM_SIZE_BYTE 32768  // 32KB
`define DATA_MEM_SIZE_BYTE  131072 // 4 x 32KB = 128KB
`define DATA_MEM_NUM_BANKS  4
`define RAM_DONE_WORD       8128

`define IN_FILE_INSTR "$GPGPU_HOME/hw/imp/sim/input/kernel_instr.mem"
`define IN_FILE_DATA  "$GPGPU_HOME/hw/imp/sim/input/kernel_data.mem"

module testbench;

    logic clk;
    logic rst_n;

    obi_req_if conf_regs_req();
    obi_rsp_if conf_regs_rsp();

    real clk_period = 100;

    gpgpu_top #(
        .INSTR_MEM_SIZE_BYTE (`INSTR_MEM_SIZE_BYTE),
        .DATA_MEM_SIZE_BYTE  (`DATA_MEM_SIZE_BYTE),
        .DATA_MEM_NUM_BANKS  (`DATA_MEM_NUM_BANKS)
    ) gpgpu_top_i (
        .clk_i               (clk),
        .rst_ni              (rst_n),
        .conf_regs_req       (conf_regs_req),
        .conf_regs_rsp       (conf_regs_rsp)
    );

    task init_vcd;
    begin
        $dumpfile("output.vcd");
    end
    endtask

    task start_vcd;
    begin
        $dumpvars(0, testbench);
    end
    endtask

    task stop_vcd;
    begin
        $dumpoff;
    end
    endtask

    task init_instr_mem;
    begin
        int i;
        for (i=0; i<`INSTR_MEM_SIZE_BYTE/4; i++) begin
            testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.instr_mem_i.sram_wrapper_i.sram_behavioral_i.mem_array[i] = 0;
        end
        $readmemh(`IN_FILE_INSTR, testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.instr_mem_i.sram_wrapper_i.sram_behavioral_i.mem_array);
    end
    endtask

    task init_data_mem;
    begin
        int i;
        logic [31:0] kernel_data[`DATA_MEM_SIZE_BYTE];

        for (i=0; i<(`DATA_MEM_SIZE_BYTE/`DATA_MEM_NUM_BANKS)/4; i++) begin
            testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.data_mem_i.gen_block[0].sram_wrapper_i.sram_behavioral_i.mem_array[i] = 0;
            testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.data_mem_i.gen_block[1].sram_wrapper_i.sram_behavioral_i.mem_array[i] = 0;
            testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.data_mem_i.gen_block[2].sram_wrapper_i.sram_behavioral_i.mem_array[i] = 0;
            testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.data_mem_i.gen_block[3].sram_wrapper_i.sram_behavioral_i.mem_array[i] = 0;
        end

        $readmemh(`IN_FILE_DATA, kernel_data);

        for (i=0; i<(`DATA_MEM_SIZE_BYTE/`DATA_MEM_NUM_BANKS)/4; i++) begin
            testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.data_mem_i.gen_block[0].sram_wrapper_i.sram_behavioral_i.mem_array[i] = kernel_data[i*4];
            testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.data_mem_i.gen_block[1].sram_wrapper_i.sram_behavioral_i.mem_array[i] = kernel_data[(i*4)+1];
            testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.data_mem_i.gen_block[2].sram_wrapper_i.sram_behavioral_i.mem_array[i] = kernel_data[(i*4)+2];
            testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.data_mem_i.gen_block[3].sram_wrapper_i.sram_behavioral_i.mem_array[i] = kernel_data[(i*4)+3];
        end
    end
    endtask

    task init_mem;
    begin
        init_instr_mem;
        init_data_mem;
    end
    endtask

    task write_conf_regs (input logic [31:0] addr, input logic [31:0] data);
    begin
        @(posedge clk);
        conf_regs_req.req   = 1'b1;
        conf_regs_req.we    = 1'b1;
        conf_regs_req.be    = 4'b1111;
        conf_regs_req.addr  = addr;
        conf_regs_req.wdata = data;

        while (!conf_regs_req.gnt)
            @(posedge clk);

        conf_regs_req.req   = 1'b0;

        while (!conf_regs_rsp.rvalid);
            @(posedge clk);
    end
    endtask

    initial begin
        rst_n = 1'b0;
        init_vcd;
        init_mem;
        start_vcd;
        #(clk_period*50);
        rst_n = 1'b1;
        write_conf_regs(32'h00000000, 32'h00000001);
        #(clk_period*50);
        write_conf_regs(32'h00000004, 32'h00000001);
    end

    always begin
        clk = 1'b0;
        #(clk_period/2);
        clk = 1'b1;
        #(clk_period/2);

        if(testbench.gpgpu_top_i.mem_hier_scratchpad_top_i.data_mem_i.gen_block[0].sram_wrapper_i.sram_behavioral_i.mem_array[`RAM_DONE_WORD][31:0] == 1) begin
            stop_vcd;
            $stop;
        end
    end

endmodule
