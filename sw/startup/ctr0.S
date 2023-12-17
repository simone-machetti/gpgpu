// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

.section .start, "ax"

  .global _start

  _start:
    la sp, __stack
    call main
    j _loop

  _loop:
    j _loop
