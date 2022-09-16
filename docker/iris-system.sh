#!/bin/bash

if [[ $1 = "local_scan" ]]; then
	START=$(date +%s)
	mopidy local scan
	echo -e "Completed in $(($(date +%s) - START)) seconds"
elif [[ $1 = "check" ]]; then
	echo -e "Access permitted"
else
	echo -e "Unsupported system task"
	exit 1
fi

exit 0