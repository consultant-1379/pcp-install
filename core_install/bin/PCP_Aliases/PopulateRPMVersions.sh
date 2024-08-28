#!/bin/bash
# ----------------------------------------------------------------------
# Ericsson Network IQ Packet Capture Pre Processor
#
# Usage:
#
#       ./PopulateRPMVersions.sh
#
#	exit 0 for success
#
# 
# ----------------------------------------------------------------------
# Copyright (c) 1999 - 2012 AB Ericsson Oy  All rights reserved.
# ----------------------------------------------------------------------
# Version 2.0
# 
# ----------------------------------------------------------------------
# This script outputs the current Operating System Software and PCP Server Software to the OUT_FILE

# String Constants
TAB="\t" # Tab is used to maintain formatting when EC builds are installed
OUT_FILE="/eniq/installation/core_install/bin/PCP_Aliases/RPMVersions" # The File to output the text to
PCP_INSTALL_RSTATE_FILE="/eniq/installation/core_install/bin/PCP_Aliases/rstate.txt" # File containing the build number from the probe installation

# Function to print the main PCP RPMs to file
function printRPMFile { # Expected input is CXC which is 3 args, Build number, RPM name
	
	bn=${#4}
	if [ "$bn" -gt "8" ]
	then
		echo -e $1 $2 $3 $TAB $4 $TAB $5      | tee -a $OUT_FILE
	else
		echo -e $1 $2 $3 $TAB $4 $TAB $TAB $5 | tee -a $OUT_FILE
	fi
}

# Function to print the PCP Platform RPMs to file
function printLIBFile { # Expected input is Build number which is 2 args and RPM name
	
	echo -e $TAB $TAB $1 $2 $TAB $3           | tee -a $OUT_FILE
}

# RPM Names
cc="ERICpcp_capture_card_conf"
pi="ERICpcp_install"
pect="ERICpcp_pect"

# CXC Number Constants
CXCcc="CXC 173 4188"
CXCpi="CXC 173 4795"
CXCpect="CXC 173 5783"

# Strings to hold the output of the rpm queries
RELpect=$(rpm -qi ERICpcp-pect-CXC1735783 | awk -- '/Release/ {print $3}')
RELcc=$(rpm -qi ERICpcp_capture_card_conf-CXC1734188 | awk -- '/Release/ {print $3}')
RELpi=$(cat $PCP_INSTALL_RSTATE_FILE)

# Outputs to OUT_FILE for main PCP RPMs
echo "Operating System Software"             | tee $OUT_FILE # Overwrite the outfile on the first write
cat /etc/*-release                           | tee -a $OUT_FILE
echo ""                                      | tee -a $OUT_FILE
echo "Packet Capture Pre-processor Software" | tee -a $OUT_FILE
printRPMFile $CXCpect $RELpect $pect
printRPMFile $CXCpi $RELpi $pi
printRPMFile $CXCcc $RELcc $cc

echo ""
echo "    [Done]    Outputted to $OUT_FILE"
echo ""
exit 0 # Success
