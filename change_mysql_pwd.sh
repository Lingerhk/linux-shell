#!/bin/bash
# author: s0nnet


if [ $# -ne 5 ]; then
    echo "Usage: $0 host base_user base_pwd user new_pwd"
    echo "Example, change password for mysql:"
    echo "$0 127.0.0.1 moresec moresec mysql mysql@pwd"
    exit 1
fi

mysql -h$1 -u$2 -p$3 -e"select User from mysql.user" > user.tmp
if [ $? -ne 0 ];then
    echo "sql commend exec faild!"
    echo "check your host, base_user or base_pwd"
    exit 1
fi

cat user.tmp | grep $4 > /dev/null
if [ $? -ne 0 ]; then
    echo "insert user($4) into mysql:"
    mysql -h$1 -u$2 -p$3 -e"insert into mysql.user(Host, User, Password) values('localhost','$4', PASSWORD('$5'))"
    mysql -h$1 -u$2 -p$3 -e"flush privileges" > /dev/null
    mysql -h$1 -u$4 -p$5 -e "select 1" > /dev/null
    if [ $? -ne 0 ];then
        echo "insert user($4) faild!"
        exit 1
    fi
    echo "insert user($4) and password($5) success!"

else
    echo "update password for $4:"
    mysql -h$1 -u$2 -p$3 -e"update mysql.user set password=PASSWORD('$5') where user='$4'" > /dev/null
    mysql -h$1 -u$2 -p$3 -e"flush privileges" > /dev/null
    mysql -h$1 -u$4 -p$5 -e"select 1" > /dev/null
    if [ $? -ne 0 ];then
        echo "update password for $4 faild!"
        exit 1
    fi
    echo "update password for $4 success!"

fi

rm -rf user.tmp
