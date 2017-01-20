#!/bin/bash

# >  svn服务器安装脚本
# >  by <www.s0nnet.com>
# >


SVN_DIR=/home/svn_home
LOG_FILE=install_svn.log

declare sys_info=""

# 执行状态log
log_to_file()
{
    echo "$1"
    echo "$1" >> ${LOG_FILE}
}

# 执行结果log
log_result()
{
    if [ $2 -ne 0  ];then
        log_to_file "[-] $1 faild!"
    else
        log_to_file "[+] $1 successed!"
    fi
}

# 检查执行结果
check_result()
{
    if [ $? -ne 0 ];then
        log_to_file "$2"
        log_result "$1" 1
        exit -1
    else
        log_to_file "$3"
    fi
}

# 获取系统版本
get_sys_version()
{
    sys_name=`cat /etc/*-release | awk -F"^NAME=" '{print $2}'`
    sys_version=`cat /etc/*-release | awk -F"^VERSION=" '{print $2}'`

    sys_info=$sys_name" "$sys_version
}

# yum安装svn
install_svn()
{
    cur_module="yum_install_svn"
    log_to_file "[*] ${cur_module}"

    check_system=`echo $sys_info | grep -p "[Cc]ent[Oo][Ss]"` >/dev/null
    if [ $? -ne 0];then
        echo "sys version error!"
	exit -1
    fi

    yum install -y subversion
    svnserve --version > /dev/null
    check_result ${cur_module} \
        "[+] install svn successed" \
        "[-] install svn failed"

    log_result ${cur_module} 0
}


# 配置svn初始化环境
conf_svn_server()
{
    cur_module="conf_svn_server"
    log_to_file "[*] ${cur_module}"

    mkdir -p $SVN_DIR
    svnadmin create $SVN_DIR

    svnserve=$SVN_DIR/conf/svnserve.conf
    cp $svnserve $svnserve.bak

    conf_list=(
        "anon-access"
        "auth-access"
        "password-db"
        "authz-db"
    )
    length=${#conf_list[@]}

    for((i=0; i<$length; i++))
    do
        item=${conf_list[$i]}
        sed -i "s/^# "${item}"/"${itme}"/g" $svnserve
    done

    log_result ${cur_module} 0
}

# 创建svn账户
add_svn_user()
{
    cur_module="add_svn_user"
    log_to_file "[*] ${cur_module}"

    cp $SVN_DIR/conf/passwd $SVN_DIR/conf/passwd.bak
    echo "admin = admin@svn" >> $SVN_DIR/conf/passwd

    log_result ${cur_module} 0
}

# 配置访问控制
conf_svn_priv()
{

    log_to_file "[!] conf_svn_priv pass ..."
}

# 启动svn服务
start_svn_service()
{
    cur_module="start_svn_service"
    log_to_file "[*] ${cur_module}"

    svnserve -d -r $SVN_DIR
    check_result ${cur_module} \
        "[+] svnserve start successed" \
        "[-] svnserve start failed"

    log_result ${cur_module} 0
}

# 添加开机自启动服务
add_authrun()
{
    cur_module="add_authrun"
    log_to_file "[*] ${cur_module}"

    echo "svnserve -d -r ${SVN_DIR}" > /etc/init.d/svnserve
    chmod +x /etc/init.d/svnserve
    chkconfig -add svnserve

    log_result ${cur_module} 0
}

# 设置iptables
setup_iptables()
{
    cur_module="tup_iptables"
    log_to_file "[*] ${cur_module}"

    iptables -I INPUT -p tcp –dport 3690 -j ACCEPT
    check_result ${cur_module} \
        "add iptables successed" \
        "add iptables failed"

    iptables save
    iptables restart
    iptables status
    
    log_result ${cur_module} 0
}

usage()
{
    echo "Usage: $0 "
    echo " install svn server at Centos"
}


main()
{
    if [ $UID -ne 0 ];then
        echo "You most run $0 with root, exit!"
        exit -1
    fi

    get_sys_version
    install_svn
    conf_svn_server
    add_svn_user
    conf_svn_priv
    start_svn_service
    add_authrun
    setup_iptables
}

main

