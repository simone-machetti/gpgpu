# Copyright 2023 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Author: Simone Machetti - simone.machetti@epfl.ch

clean:
	rm -rf vendor/vortex
	rm -rf vendor/vortex.lock.hjson

src-gen-all: src-gen-vendor

src-gen-vendor:
	cd vendor && \
	python3 vendor.py vortex.vendor.hjson --update
