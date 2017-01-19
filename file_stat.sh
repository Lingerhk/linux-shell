#!/bin/bash

# >  desc: 文件类型统计
# >  author: s0nnet
# >  time: 2017-01-19

if [ $# -ne 1 ];then
    echo "Usage is $0 basepath";
    exit
fi

path=$1
declare -A stat_array;

while read line;
do
    ftype=`file -b "$line" | cut -d, -f1`
    let stat_array["$ftype"]++;

done < <(find $path -type f -print)

echo Find:

for ftype in "${!stat_array[@]}";
do
    echo $ftype: ${stat_array["$ftype"]}
done


