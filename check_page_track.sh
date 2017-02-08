#!/bin/bash

# >  desc: check webpage track.sh
# >  author: s0nnet
# >  time: 2017-02-08

if [ $# -ne 1 ];then
    echo -e "Usage: $0 URL"
    exit 1
fi

first_time=0

if [ ! -e "last.html" ];then
    first_time=1
fi

curl --silent $1 -o recent.html
if [ $first_time -ne 1 ];then
    changes=$(diff -u last.html recent.html)
    if [ -n "$changes" ];then
        echo -e "Changes:"
        echo "$changes"
    else
        echo -e "\nWebsite has no changes"
    fi
else
    echo "First run, Archiving..."
fi

cp recent.html last.html
