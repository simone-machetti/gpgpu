// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

`define RAM_SIZE_WORD 32768

`define RAM_DONE_ADDR 7936

`define IN_FILE  "$GPGPU_HOME/hw/imp/sim/input/kernel.mem"
`define OUT_FILE "$GPGPU_HOME/hw/imp/sim/output/output.mem"

task init_ram;
begin
    int i;
    for (i=0; i<`RAM_SIZE_WORD; i++) begin
        testbench.dual_port_ram_i.mem_array[i] = 0;
    end
    $readmemh(`IN_FILE, testbench.dual_port_ram_i.mem_array);
end
endtask

task dump_ram;
begin
    int fd;
    int i;
    fd = $fopen(`OUT_FILE, "w");
    for (i=0; i<`RAM_SIZE_WORD; i++) begin
        $fdisplay(fd, "%X", testbench.dual_port_ram_i.mem_array[i]);
    end
end
endtask

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

module testbench (
);
    logic clk;
    logic rst_n;

    obi_req_if instr_req();
    obi_rsp_if instr_rsp();

    obi_req_if data_req();
    obi_rsp_if data_rsp();

    gpgpu_top gpgpu_top_i (
        .clk_i         (clk),
        .rst_ni        (rst_n),
        .instr_mem_req (instr_req),
        .instr_mem_rsp (instr_rsp),
        .data_mem_req  (data_req),
        .data_mem_rsp  (data_rsp)
    );

    dual_port_ram # (
        .MEM_SIZE_WORD (`RAM_SIZE_WORD)
    ) dual_port_ram_i (
        .clk_i         (clk),
        .rst_ni        (rst_n),
        .instr_mem_req (instr_req),
        .instr_mem_rsp (instr_rsp),
        .data_mem_req  (data_req),
        .data_mem_rsp  (data_rsp)
    );

    real clk_freq   = 100;
    real clk_period = 1000;

    initial begin
        rst_n = 1'b0;
        init_vcd;
        init_ram;
        start_vcd;
        #(clk_period*100);
        #(clk_period/4);
        rst_n = 1'b1;
    end

    always begin
        clk = 1'b0;
        #(clk_period/2);
        clk = 1'b1;
        #(clk_period/2);
        if(testbench.dual_port_ram_i.mem_array[`RAM_DONE_ADDR][31:0] == 1) begin
            stop_vcd;
            dump_ram;
            $stop;
        end
    end

endmodule
