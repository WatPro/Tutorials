#!/bin/bash

################################################################################
########## Install Apache HTTP server benchmarking tool               ##########
########## Dependencies: (None)                                       ##########
################################################################################

############################################################
# find out the package and the installation path by:       #
# #yum provides ab                                         #
############################################################

yum --assumeyes install /usr/bin/ab

