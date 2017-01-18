#!/bin/bash

# >  SVN服务器迁移脚本
# >  desc: 采用 svnadmin hotcopy的方式进行
# >  by: s0nnet<www.s0nnet.com>
# >  date: 2017-01-18



SVN_DIR=/var/svn_server
SVN_BAK=/var/svn_backup

SSH_ADDR=root@172.16.94.130
SSH_PASS=xxxx

#setup1: hotcopy srouce code
if [ ! -d ${SVN_BAK} ];then
    mkdir ${SVN_BAK}
fi
svnadmin hotcopy $SVN_DIR ${SVN_BAK}/svn_data
SVN_PKG=svn_data_`date +%F`.tar.gz
cd $SVN_BAK;
tar zcf ${SVN_PKG} svn_data

#setup2: scp tar package
yg_ssh.exp ${SSH_PASS} ssh ${SSH_ADDR} "mkdir ${SVN_BAK}; mkdir ${SVN_DIR}"
yg_ssh.exp ${SSH_PASS} scp ${SVN_BAK}/${SVN_PKG} ${SSH_ADDR}:${SVN_BAK}
yg_ssh.exp ${SSH_PASS} ssh ${SSH_ADDR} "cd ${SVN_BAK}; tar zxvf ${SVN_PKG}; svnadmin hotcopy svn_data ${SVN_DIR}"
yg_ssh.exp ${SSH_PASS} ssh ${SSH_ADDR} "svnserve -d -r ${SVN_DIR}"

