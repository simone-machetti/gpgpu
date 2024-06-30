# Copyright 2023 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Author: Simone Machetti - simone.machetti@epfl.ch

RAM_BLOCK_SIZE = 1

VX_CC  = $(RISCV_TOOLCHAIN_PATH)/bin/riscv32-unknown-elf-gcc
VX_DP  = $(RISCV_TOOLCHAIN_PATH)/bin/riscv32-unknown-elf-objdump
VX_CP  = $(RISCV_TOOLCHAIN_PATH)/bin/riscv32-unknown-elf-objcopy

VX_CFLAGS += -march=rv32imf -mabi=ilp32f -O3 -Wstack-usage=1024 -ffreestanding -nostartfiles -fdata-sections -ffunction-sections

VX_LDFLAGS += -Wl,-Bstatic,-T,$(GPGPU_HOME)/sw/link/link32.ld -Wl,--gc-sections

VX_SRCS = $(GPGPU_HOME)/sw/apps/$(APP_NAME)/src/kernel.c $(GPGPU_HOME)/sw/startup/ctr0.S

all: kernel.bin kernel.dump

kernel.dump: kernel.elf
	$(VX_DP) -D $(GPGPU_HOME)/sw/apps/$(APP_NAME)/build/kernel.elf > $(GPGPU_HOME)/sw/apps/$(APP_NAME)/build/kernel.dump

kernel.bin: kernel.elf
	$(VX_CP) -O binary $(GPGPU_HOME)/sw/apps/$(APP_NAME)/build/kernel.elf $(GPGPU_HOME)/sw/apps/$(APP_NAME)/build/kernel.bin
	mkdir -p $(GPGPU_HOME)/hw/imp/sim/input
	python3 $(GPGPU_HOME)/sw/tools/bin2mem.py $(RAM_BLOCK_SIZE) $(GPGPU_HOME)/sw/apps/$(APP_NAME)/build $(GPGPU_HOME)/hw/imp/sim/input

kernel.elf: $(VX_SRCS)
	mkdir -p $(GPGPU_HOME)/sw/apps/$(APP_NAME)/build
	$(VX_CC) $(VX_CFLAGS) $(VX_SRCS) $(VX_LDFLAGS) -o $(GPGPU_HOME)/sw/apps/$(APP_NAME)/build/kernel.elf

clean:
	rm -rf $(GPGPU_HOME)/sw/apps/$(APP_NAME)/build
	rm -rf $(GPGPU_HOME)/sw/apps/$(APP_NAME)/work
	rm -rf $(GPGPU_HOME)/sw/apps/$(APP_NAME)/transcript
	rm -rf $(GPGPU_HOME)/hw/imp/sim/input
	rm -rf $(GPGPU_HOME)/hw/imp/sim/output

run:
	cd $(GPGPU_HOME)/sw/apps/$(APP_NAME) && \
	mkdir -p $(GPGPU_HOME)/hw/imp/sim/output && \
	vsim -c -do $(GPGPU_HOME)/hw/imp/sim/scripts/gpgpu.tcl && \
	mv $(GPGPU_HOME)/sw/apps/$(APP_NAME)/output.vcd $(GPGPU_HOME)/hw/imp/sim/output

wave:
	gtkwave $(GPGPU_HOME)/hw/imp/sim/output/output.vcd &
