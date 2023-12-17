// Copyright 2023 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Author: Simone Machetti - simone.machetti@epfl.ch

#include <stdio.h>
#include "kernel.h"

// ---------------------------------------------------------------------
// This piece of code virtualizes a host platform
// ---------------------------------------------------------------------
#define LENGTH 10

volatile unsigned int vec_a[LENGTH] = {0,1,2,3,4,5,6,7,8,9};
volatile unsigned int vec_b[LENGTH] = {0,0,0,0,0,0,0,0,0,0};

void virtual_host(void)
{
  args.len = (unsigned int)LENGTH;
  args.src_addr = (unsigned int)vec_a;
  args.dst_addr = (unsigned int)vec_b;

  return;
}

// ---------------------------------------------------------------------
// This piece of code is the actual GPGPU kernel
// ---------------------------------------------------------------------
void main() {

	virtual_host();

	unsigned int len = (unsigned int)args.len;
	unsigned int* src_ptr = (unsigned int*)args.src_addr;
	unsigned int* dst_ptr = (unsigned int*)args.dst_addr;

	for (unsigned int i = 0; i < len; ++i) {
		dst_ptr[i] = src_ptr[i];
	}

  for (int i=0; i<10; i++)
  {
    if (dst_ptr[i] != src_ptr[i])
    {
      args.done = 2;
      while(1);
    }
  }

  args.done = 1;

  while(1);
}
