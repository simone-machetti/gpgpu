/* Copyright 2023 EPFL
*  Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
*  SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
*
*  Author: Simone Machetti - simone.machetti@epfl.ch */

OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  CODE_RAM (RWX) : ORIGIN = 0x00000000 , LENGTH = 0x7C00
  ARGS_RAM (RW)  : ORIGIN = 0x00007C00 , LENGTH = 0x0400
}

__stack = ORIGIN(CODE_RAM) + LENGTH(CODE_RAM);
__stack_size = 2K;

SECTIONS
{
  .start MAX(0x00000000, ALIGN(4)) :
  {
    . = ALIGN(4);
    *(.start*)
    . = ALIGN(4);
  } > CODE_RAM

  .text :
  {
    . = ALIGN(4);
    *(.text*)
    . = ALIGN(4);
  } > CODE_RAM

  .data :
  {
    . = ALIGN(4);
    *(.data*)
    . = ALIGN(4);
  } > CODE_RAM

  .rodata :
  {
    . = ALIGN(4);
    *(.rodata*)
    . = ALIGN(4);
  } > CODE_RAM

  .bss :
  {
    . = ALIGN(4);
    *(.bss*)
    . = ALIGN(4);
  } > CODE_RAM

  .stack :
  {
    . = ALIGN(4);
    . = . + __stack_size;
    . = ALIGN(4);
  } > CODE_RAM

  .args : {
    . = ALIGN(4);
    *(.args)
    . = ALIGN(4);
  } > ARGS_RAM
}
