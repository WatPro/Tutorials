#!/bin/bash

################################################################################
########## Install wrk                                                ##########
########## Dependencies: (None)                                       ##########
################################################################################
 
I_PATH=/usr/local
G_URL=https://github.com/wg/wrk.git
G_DIR=${G_URL##*/}
G_DIR=${G_DIR%.*}

yum --assumeyes groupinstall "Development Tools" 
yum --assumeyes install openssl-devel git 
cd "$I_PATH"
git clone "$G_URL"
cd "$G_DIR"

############################################################
# Install                                                  #
# make install is not available                            #
# (make: No rule to make target `install'                  #
############################################################
make
cp wrk "$I_PATH/bin"

rm --force --recursive "$I_PATH/$G_DIR"


