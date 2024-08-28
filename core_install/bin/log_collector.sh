#!/bin/bash

function log_collect()
{
	echo "collecting log file in directory /var/log/ericsson/pcp/"
	output=/var/log/ericsson/pcp/log_snapshots_`date +"%Y_%m_%d_%H_%M_%S"`.tar.gz
	tar -zcvf $output /var/log/ericsson/pcp/*.log*
	echo "output file name is $output"
}


log_collect
