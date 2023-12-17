// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

#ifndef _KERNEL_H_
#define _KERNEL_H_

typedef struct {
  volatile unsigned int done;
  volatile unsigned int len;
  volatile unsigned int src_addr;
  volatile unsigned int dst_addr;
} kernel_args_t;

__attribute__((section(".args"))) kernel_args_t args;

#endif
