#!/bin/env python
# -*- coding: utf-8 -*-

import os

statefolder = os.path.join(os.environ['GOTOPATH'], '.state', 'projects')
print("setting up goto-state-folder in ",  statefolder)

if not os.path.exists(statefolder):
	os.makedirs(statefolder)
	print("created all goto directories")
