#!/bin/bash
# ----------------------------------------------------------------------
# Ericsson Network IQ Packet Capture Pre Processor Installation Test
#
# Usage:
#
#       ./check_Install_OK.sh
#
#	exit 0 for success
#	exit 1 for no Directory
#	exit 2 for no File or Link
#
# read file pcp_files.txt for for all files that should exist
# read file pcp_dir_structure.txt for for all directories that should exist
# read file pcp_rpm.txt for for all rpm instalations that should exist
# ----------------------------------------------------------------------
# Copyright (c) 1999 - 2012 AB Ericsson Oy  All rights reserved.
# ---------------------------------------------------------------------
#
# Version 1.30
#
# Update to include check for install tar package
#
# Version 1.2
# 
# 
EXIT_SUCCESS=0
EXIT_NO_DIR=1
EXIT_NO_FILE=2
EXIT_BAD_PKG=3
EXIT_BAD_TAR=4

WORKING_DIR="/eniq/installation/core_install/bin/checkInstallScripts"

function CHECK_DIR_EXISTS {

	#echo "$1"
	if [ -d "$1" ]
	then
		echo "    [TEST]    DIR : " $1 " exists"
	else
		echo "."
		echo "    [TEST]    DIR : $1 does not exist"
		echo "    [FAIL]    DIRECTORY MISSING"
    echo ""
		exit $EXIT_NO_DIR
	fi
}

function CHECK_FILE_EXISTS {

	#echo $1
	if [ -f "$1" ]
	then
		echo "    [TEST]    FILE : " $1 " exists"
	else
		if [ -L "$1" ]
		then
			echo "    [TEST]    LINK : " $1 " exists"
		else
			echo .
			echo "    [TEST]    FILE OR LINK : " $1 "does not exist"
			echo "    [FAIL]    FILE OR LINK MISSING"
      echo ""
			exit $EXIT_NO_FILE
		fi
	fi
}

function CHECK_RPM_VERSION {
	
	STATUS=0
	STATUS=$( rpm -qi $1 |grep 'Version' |grep -c $2 )
	if [ $STATUS -eq 0 ]
	then
		echo .
		echo "    [TEST]    PACKAGE: " $1 "HAS INCORRECT VERSION: REQUIRED VERSION = " $2
    echo "    [FAIL]    PACKAGE VERSION INCORRECT"
    echo ""

		exit $EXIT_BAD_PKG
	else
		echo "    [TEST]    PACKAGE: " $1 "HAS CORRECT VERSION:" $2
	fi
}

function CHECK_RPM_DATE {
	
	STATUS=0
	#echo $2 $3 $4
	STATUS=$( rpm -qi $1 |grep 'Build Date' |grep -c $2 )
	
	if [ $STATUS -eq 0 ]
	then
		echo .
		echo "PACKAGE: " $1 "HAS INCORRECT RELEASE DATE: REQUIRED DAY = " $2
		exit $EXIT_BAD_PKG
	else
		echo "PACKAGE: " $1 "HAS CORRECT RELEASE DATE: " $2
	fi
	
	STATUS=$( rpm -qi $1 |grep 'Build Date' |grep -c $3 )
	if [ $STATUS -eq 0 ]
	then
		echo .
		echo "PACKAGE: " $1 "HAS INCORRECT RELEASE DATE: REQUIRED MONTH = " $3
		exit $EXIT_BAD_PKG
	else
		echo "PACKAGE: " $1 "HAS CORRECT RELEASE DATE: " $3
	fi
	
	STATUS=$( rpm -qi $1 |grep 'Build Date' |grep -c $4 )
	if [ $STATUS -eq 0 ]
	then
		echo .
		echo "PACKAGE: " $1 "HAS INCORRECT RELEASE DATE: REQUIRED YEAR = " $4
		exit $EXIT_BAD_PKG
	else
		echo "PACKAGE: " $1 "HAS CORRECT RELEASE DATE: " $4
	fi
}

function CHECK_TAR_EXISTS {

	#echo $1
	if [ -f "$1" ]
	then
		echo "    [TEST]    TAR PACKAGE: " $1 " PRESENT"
	else
    echo .
    echo "    [TEST]    TAR PACKAGE: " $1 "does not exist"
    echo "    [FAIL]    TAR PACKAGE MISSING"
    echo ""

    exit $EXIT_BAD_TAR
	fi
}

# main()

echo "    [START]   Starting checking that the installed directories, file and RPMs are correct."
echo ""
# read file pcp_dir_structure.txt for for all directories that should exist
# A # in the line is a comment so ignore it

echo "    [INFO]    Checking the directories."
while read line
do
	#echo $line
	DIR_SECTION=$( echo `expr index "$line" '#'` )
	#echo $DIR_SECTION
	if [ $DIR_SECTION == 0 ]
	then
		CHECK_DIR_EXISTS $line
	fi
done < $WORKING_DIR/pcp_dir_structure.txt 
echo "    [PASS]    All expected directories are present."
echo ""
# read file pcp_files.txt for for all files that should exist
# A # in the line is a comment so ignore it

echo "    [INFO]    Checking the files."
while read line
do
	#echo $line
	DIR_SECTION=$( echo `expr index "$line" '#'` )
	#echo $DIR_SECTION
 	if [ $DIR_SECTION == 0 ]
	then
		CHECK_FILE_EXISTS $line
	fi
done < $WORKING_DIR/pcp_files.txt
echo "    [PASS]    All expected files are present."
echo ""
echo "    [INFO]    Checking the RPMs."
# elukpot: Commenting out all the date stuff, as it's problematic - 07/Dec/2012
while read pkg ver #dd mm yyyy
do
	DIR_SECTION=$( echo `expr index "$pkg" '#'` )
	#echo $DIR_SECTION
	if [ $DIR_SECTION == 0 ]
	then
		#myDATE=$( echo $dd $mm $yyyy )
		#echo $pkg ": "$ver ": " $myDATE
		CHECK_RPM_VERSION $pkg $ver
		#CHECK_RPM_DATE $pkg $dd $mm $yyyy
	fi
done < $WORKING_DIR/pcp_rpm_packages.txt
echo "    [PASS]    All expected RPMs are present."

echo ""
echo "    [INFO]    Checking the TARs."
while read tar_pkg
  do
  DIR_SECTION=$( echo `expr index "$tar_pkg" '#'` )
	#echo $DIR_SECTION
	if [ $DIR_SECTION == 0 ]
	then
    CHECK_TAR_EXISTS "$tar_pkg"
  fi
done<pcp_tar.txt  


echo "    [PASS]    All expected TARs are present."
echo ""
echo "    [FINISH]  All expected directories, files, RMP and TARs are present."
exit $EXIT_SUCCESS
