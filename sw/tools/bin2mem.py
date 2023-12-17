# Copyright 2023 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Author: Simone Machetti - simone.machetti@epfl.ch

import binascii
import sys

block_size = int(sys.argv[1])
in_file_path  = "{}".format(sys.argv[2])
out_file_path  = "{}".format(sys.argv[3])

tmp = []
out = []
n = 0
with open("{}/kernel.bin".format(in_file_path), 'rb') as fi:

	while True:
		byte_0 = fi.read(1).hex()
		byte_1 = fi.read(1).hex()
		byte_2 = fi.read(1).hex()
		byte_3 = fi.read(1).hex()
		word   = byte_3 + byte_2 + byte_1 + byte_0
		if not word:
			break
		tmp.append(word)
		n = n + 1

	blocks = int(n / block_size)
	rest = n % block_size

	with open("{}/kernel.mem".format(out_file_path), 'w') as file:
		for i in range(blocks):
			for j in range(block_size):
				out.append(tmp[i * block_size + block_size - 1 - j])
			block = ''.join(out)
			file.write('%s\n' % block)
			del out[:]

		if rest != 0:
			for i in range(block_size - rest):
				out.append("00000000")
			for j in range(rest):
				out.append(tmp[blocks * block_size + rest - 1 - j])
			block = ''.join(out)
			file.write('%s\n' % block)
