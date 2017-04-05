#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS Debian or Ubuntu (32bit/64bit)
#   Description:  A tool to auto-compile & install KCPTUN for SS/SSR on Linux
#   Intro: https://github.com/onekeyshell/kcptun_for_ss_ssr/issues
#===============================================================================================
version="1.9.9"
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install SS/SSR/KCPTUN"
    exit 1
fi
shell_update(){
    fun_clangcn "clear"
    echo "+ Check updates for shell..."
    remote_shell_version=`wget --no-check-certificate -qO- ${shell_download_link} | sed -n '/'^version'/p' | cut -d\" -f2`
    if [ ! -z ${remote_shell_version} ]; then
        if [[ "${version}" != "${remote_shell_version}" ]];then
            echo -e "${COLOR_GREEN}Found a new version,update now!!!${COLOR_END}"
            echo
            echo -n "+ Update shell ..."
            if ! wget --no-check-certificate -qO $0 ${shell_download_link}; then
                echo -e " [${COLOR_RED}failed${COLOR_END}]"
                echo
                exit 1
            else
                echo -e " [${COLOR_GREEN}OK${COLOR_END}]"
                echo
                echo -e "${COLOR_GREEN}Please Re-run${COLOR_END} ${COLOR_PINK}$0 ${clang_action}${COLOR_END}"
                echo
                exit 1
            fi
            exit 1
        fi
    fi
}
shell_download_link="https://raw.githubusercontent.com/FIREU666/onekey-kcp/master/kcp-install.sh"
program_version_link="https://raw.githubusercontent.com/FIREU666/onekey-kcp/master/version.sh"
ss_libev_config="/etc/shadowsocks-libev/config.json"
ssr_config="/usr/local/shadowsocksR/shadowsocksR.json"
kcptun_config="/usr/local/kcptun/config.json"
# Check if user is root

fire_check(){
    local clear_flag=""
    clear_flag=$1
    if [[ ${clear_flag} == "clear" ]]; then
        clear
    fi
    echo ""
    echo "+----------------------------------------------------------------+"
    echo "|                KCPTUN for SS/SSR on Linux Server               |"
    echo "+----------------------------------------------------------------+"
    echo "|  One key to install KCPTUN for SS/SSR on Linux   |"
    echo "+----------------------------------------------------------------+"
    echo "| Intro:FIREU666 |"
    echo "+----------------------------------------------------------------+"
    echo ""
}
fun_set_text_color(){
    COLOR_RED='\E[1;31m'
    COLOR_GREEN='\E[1;32m'
    COLOR_YELOW='\E[1;33m'
    COLOR_BLUE='\E[1;34m'
    COLOR_PINK='\E[1;35m'
    COLOR_PINKBACK_WHITEFONT='\033[45;37m'
    COLOR_GREEN_LIGHTNING='\033[32m \033[05m'
    COLOR_END='\E[0m'
}
# Check OS
Get_Dist_Name(){
    release=''
    systemPackage=''
    DISTRO=''
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "centos|red hat|redhat" /etc/issue || grep -Eqi "centos|red hat|redhat" /etc/*-release; then
        DISTRO='RHEL'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        release="debian"
        systemPackage='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        release="ubuntu"
        systemPackage='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        release="debian"
        systemPackage='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        release="debian"
        systemPackage='apt'
    else
        release='unknow'
    fi
    Get_OS_Bit
}
# Check OS bit
Get_OS_Bit(){
    ARCHS=""
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
        ARCHS="amd64"
    else
        Is_64bit='n'
        ARCHS="386"
    fi
}
# Check system
check_sys(){
    local checkType=$1
    local value=$2
    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ]; then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [ "$value" == "$systemPackage" ]; then
            return 0
        else
            return 1
        fi
    fi
}
# Get version
getversion(){
if [[ -s /etc/redhat-release ]]; then
    grep -oE  "[0-9.]+" /etc/redhat-release
else
    grep -oE  "[0-9.]+" /etc/issue
fi
}
# CentOS version
centosversion(){
    if check_sys sysRelease centos; then
        local code=$1
        local version="$(getversion)"
        local main_ver=${version%%.*}
        if [ "$main_ver" == "$code" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
get_opsy(){
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}
debianversion(){
    if check_sys sysRelease debian;then
        local version=$( get_opsy )
        local code=${1}
        local main_ver=$( echo ${version} | sed 's/[^0-9]//g')
        if [ "${main_ver}" == "${code}" ];then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
Check_OS_support(){
    # Check OS system
    if [ "${release}" == "unknow" ]; then
        echo
        echo -e "${COLOR_RED}Error: Unable to get Linux distribution name, or do NOT support the current distribution.${COLOR_END}"
        echo
        exit 1
    elif [ "${DISTRO}" == "CentOS" ]; then
        if centosversion 5; then
            echo
            echo -e "${COLOR_RED}Not support CentOS 5, please change to CentOS 6 or 7 and try again.${COLOR_END}"
            echo
            exit 1
        fi
    fi
}
Press_Install(){
    echo ""
    echo -e "${COLOR_GREEN}Press any key to install...or Press Ctrl+c to cancel${COLOR_END}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}

Press_Start(){
    echo ""
    echo -e "${COLOR_GREEN}Press any key to continue...or Press Ctrl+c to cancel${COLOR_END}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}
Press_Exit(){
    echo ""
    echo -e "${COLOR_GREEN}Press any key to Exit...or Press Ctrl+c${COLOR_END}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}
Print_Sys_Info(){
    cat /etc/issue
    cat /etc/*-release
    uname -a
    MemTotal=`free -m | grep Mem | awk '{print  $2}'`
    echo "Memory is: ${MemTotal} MB "
    df -h
}
Disable_Selinux(){
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}
pre_install_packs(){
    local wget_flag=''
    local killall_flag=''
    local netstat_flag=''
    wget --version > /dev/null 2>&1
    wget_flag=$?
    killall -V >/dev/null 2>&1
    killall_flag=$?
    netstat --version >/dev/null 2>&1
    netstat_flag=$?
    if [[ ${wget_flag} -gt 1 ]] || [[ ${killall_flag} -gt 1 ]] || [[ ${netstat_flag} -gt 6 ]];then
        echo -e "${COLOR_GREEN} Install support packs...${COLOR_END}"
        if check_sys packageManager yum; then
            yum install -y wget psmisc net-tools
        elif check_sys packageManager apt; then
            apt-get -y update && apt-get -y install wget psmisc net-tools
        fi
    fi
}

get_ip(){
    local IP=$(ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1)
    [ -z ${IP} ] && IP=$(wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$(wget -qO- -t1 -T2 ipinfo.io/ip )
    [ ! -z ${IP} ] && echo ${IP} || echo
}
Dispaly_Selection(){
    def_Install_Select="1"
    echo -e "${COLOR_YELOW}You will install kcptun/ss/ssr.${COLOR_END}"
    read -p "[${def_Install_Select}]): " Install_Select

    case "${Install_Select}" in
    1)
        echo
        echo -e "${COLOR_PINK}You will install KCPTUN ${KCPTUN_VER}${COLOR_END}"
        ;;
    [eE][xX][iI][tT])
        echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
        exit 1
        ;;
    *)
        echo
        echo -e "${COLOR_PINK}No input,You will install KCPTUN${COLOR_END}"
        Install_Select="${def_Install_Select}"
    esac
}
# Install cleanup
install_cleanup(){
    cd ${cur_dir}
    rm -rf .version.sh ${shadowsocks_libev_ver} ${shadowsocks_libev_ver}.tar.gz manyuser.zip shadowsocksr-manyuser shadowsocks-manyuser ${kcptun_latest_file} ${libsodium_laster_ver} ${libsodium_laster_ver}.tar.gz ${mbedtls_laster_ver} ${mbedtls_laster_ver}-gpl.tgz
}
check_kcptun_for_ss_ssr_installed(){
    kcptun_installed_flag=""
    kcptun_install_flag=""
    if [ "${Install_Select}" == "3" ] || [ "${Update_Select}" == "3" ] || [ "${Update_Select}" == "4" ] || [ "${Uninstall_Select}" == "3" ] || [ "${Uninstall_Select}" == "4" ]; then
        if [[ "$(command -v "/usr/local/kcptun/kcptun")" ]] || [[ "$(command -v "kcptun")" ]]; then
            kcptun_installed_flag="true"
        else
            kcptun_installed_flag="false"
        fi
    fi
}
get_install_version(){
    rm -f ${cur_dir}/.version.sh
    if ! wget --no-check-certificate -qO ${cur_dir}/.version.sh ${program_version_link}; then
        echo -e "${COLOR_RED}Failed to download version.sh${COLOR_END}"
    fi
    if [ -s ${cur_dir}/.version.sh ]; then
        [ -x ${cur_dir}/.version.sh ] && chmod +x ${cur_dir}/.version.sh 
        . ${cur_dir}/.version.sh
    fi
    if [ -z ${LIBSODIUM_VER} ] || [ -z ${MBEDTLS_VER} ] || [ -z ${SS_LIBEV_VER} ] || [ -z ${SSR_VER} ] || [ -z ${KCPTUN_VER} ]; then
        echo -e "${COLOR_RED}Error: ${COLOR_END}Get Program version failed!"
        exit 1
    fi
}
get_latest_version(){
    rm -f ${cur_dir}/.api_*.txt 
    if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ss_libev_installed_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading SS-libev version, please wait..."
        if check_sys packageManager yum; then
            ss_libev_init_link="${SS_LIBEV_YUM_INIT}"
        elif check_sys packageManager apt; then
            ss_libev_init_link="${SS_LIBEV_APT_INIT}"
        fi
        shadowsocks_libev_ver="shadowsocks-libev-${SS_LIBEV_VER}"
        if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the ss-libev version:${COLOR_GREEN} ${SS_LIBEV_VER}${COLOR_END}"
        fi
    fi
    if [ ! -f /usr/lib/libsodium.a ] && [ ! -L /usr/local/lib/libsodium.so ]; then
        #echo -e "Loading libsodium version, please wait..."
        libsodium_laster_ver="libsodium-${LIBSODIUM_VER}"
        if [ "${libsodium_laster_ver}" == "" ] || [ "${LIBSODIUM_LINK}" == "" ]; then
            echo -e "${COLOR_RED}Error: Get libsodium version failed${COLOR_END}"
            exit 1
        fi
        #echo -e "Get the libsodium version:${COLOR_GREEN} ${LIBSODIUM_VER}${COLOR_END}"
    fi
    if [ ! -f /usr/lib/libmbedtls.a ] && [ ! -f /usr/include/mbedtls/version.h ]; then
        #echo -e "Loading mbedtls version, please wait..."
        mbedtls_laster_ver="mbedtls-${MBEDTLS_VER}"
        if [ "${mbedtls_laster_ver}" == "" ] || [ "${MBEDTLS_LINK}" == "" ]; then
            echo -e "${COLOR_RED}Error: Get mbedtls version failed${COLOR_END}"
            exit 1
        fi
        #echo -e "Get the mbedtls version:${COLOR_GREEN} ${MBEDTLS_VER}${COLOR_END}"
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading ShadowsocksR version, please wait..."
        ssr_download_link="${SSR_LINK}"
        ssr_latest_ver="${SSR_VER}"
        if check_sys packageManager yum; then
            ssr_init_link="${SSR_YUM_INIT}"
        elif check_sys packageManager apt; then
            ssr_init_link="${SSR_APT_INIT}"
        fi
        if [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the ShadowsocksR version:${COLOR_GREEN} ${SSR_VER}${COLOR_END}"
        fi
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading kcptun version, please wait..."
        kcptun_init_link="${KCPTUN_INIT}"
        kcptun_latest_file="kcptun-linux-${ARCHS}-${KCPTUN_VER}.tar.gz"
        if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
            kcptun_download_link="${KCPTUN_AMD64_LINK}"
        else
            kcptun_download_link="${KCPTUN_386_LINK}"
        fi
        if [[ "${kcptun_init_link}" == "" || "${kcptun_download_link}" == "" ]]; then
            echo -e "${COLOR_RED}Error: Get kcptun version failed${COLOR_END}"
            exit 1
        fi
        if [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the kcptun version:${COLOR_GREEN} ${kcptun_latest_file}${COLOR_END}"
        fi
    fi
}
# Download latest
down_kcptun_for_ss_ssr(){
    if [ ! -f /usr/lib/libsodium.a ] && [ ! -L /usr/local/lib/libsodium.so ]; then
        if [ -f ${libsodium_laster_ver}.tar.gz ]; then
            echo "${libsodium_laster_ver}.tar.gz [found]"
        else
            if ! wget --no-check-certificate -O ${libsodium_laster_ver}.tar.gz ${LIBSODIUM_LINK}; then
                echo -e "${COLOR_RED}Failed to download ${libsodium_laster_ver}.tar.gz${COLOR_END}"
                exit 1
            fi
        fi
    fi
    if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ss_libev_installed_flag}" == "true" && "${ss_libev_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f ${shadowsocks_libev_ver}.tar.gz ]; then
            echo "${shadowsocks_libev_ver}.tar.gz [found]"
        else
            if ! wget --no-check-certificate -O ${shadowsocks_libev_ver}.tar.gz ${SS_LIBEV_LINK}; then
                echo -e "${COLOR_RED}Failed to download ${shadowsocks_libev_ver}.tar.gz${COLOR_END}"
                exit 1
            fi
        fi

        # Download init script
        if ! wget --no-check-certificate -O /etc/init.d/shadowsocks ${ss_libev_init_link}; then
            echo -e "${COLOR_RED}Failed to download shadowsocks-libev init script!${COLOR_END}"
            exit 1
        fi
        if [ ! -f /usr/lib/libmbedtls.a ] && [ ! -f /usr/include/mbedtls/version.h ]; then
            if [ -f ${mbedtls_laster_ver}-gpl.tgz ]; then
                echo "${mbedtls_laster_ver}-gpl.tgz [found]"
            else
                if ! wget --no-check-certificate -O ${mbedtls_laster_ver}-gpl.tgz ${MBEDTLS_LINK}; then
                    echo -e "${COLOR_RED}Failed to download ${mbedtls_laster_ver}-gpl.tgz${COLOR_END}"
                    exit 1
                fi
            fi
        fi
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "true" && "${ssr_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f manyuser.zip ]; then
            echo "manyuser.zip [found]"
        else
            if ! wget --no-check-certificate -O manyuser.zip ${ssr_download_link}; then
                echo -e "${COLOR_RED}Failed to download ShadowsocksR file!${COLOR_END}"
                exit 1
            fi
        fi
        if ! wget --no-check-certificate -O /etc/init.d/ssr ${ssr_init_link}; then
            echo -e "${COLOR_RED}Failed to download ShadowsocksR init script!${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "true" && "${kcptun_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f ${kcptun_latest_file} ]; then
            echo "${kcptun_latest_file} [found]"
        else
            if ! wget --no-check-certificate -O ${kcptun_latest_file} ${kcptun_download_link}; then
                echo -e "${COLOR_RED}Failed to download ${kcptun_latest_file}${COLOR_END}"
                exit 1
            fi
        fi
        if ! wget --no-check-certificate -O /etc/init.d/kcptun ${kcptun_init_link}; then
            echo -e "${COLOR_RED}Failed to download kcptun init script!${COLOR_END}"
            exit 1
        fi
    fi
}
config_kcptun_for_ss_ssr(){
    if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
        [ ! -d /etc/shadowsocks-libev ] && mkdir -p /etc/shadowsocks-libev
        cat > ${ss_libev_config}<<-EOF
{
    "server":"0.0.0.0",
    "server_port":${set_ss_libev_port},
    "local_address":"127.0.0.1",
    "local_port":${ss_libev_local_port},
    "password":"${set_ss_libev_pwd}",
    "timeout":600,
    "method":"${set_ss_libev_method}"
}
EOF
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
    [ ! -d /usr/local/shadowsocksR ] && mkdir -p /usr/local/shadowsocksR
    cat > ${ssr_config}<<-EOF
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":${ssr_local_port},
    "port_password":{
        "${set_ssr_port}":"${set_ssr_pwd}"
    },
    "timeout":120,
    "method":"${set_ssr_method}",
    "protocol":"${set_ssr_protocol}",
    "protocol_param":"",
    "obfs":"${set_ssr_obfs}",
    "obfs_param":"",
    "redirect":"",
    "dns_ipv6":false,
    "fast_open":false,
    "workers":1
}
EOF
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
        [ ! -d /usr/local/kcptun ] && mkdir -p /usr/local/kcptun
        # Config file
        cat > ${kcptun_config}<<-EOF
{
    "listen": ":${set_kcptun_port}",
    "target": "127.0.0.1:${kcptun_target_port}",
    "key": "${set_kcptun_pwd}",
    "crypt": "${set_kcptun_method}",
    "mode": "${set_kcptun_mode}",
    "mtu": ${set_kcptun_mtu},
    "sndwnd": 1024,
    "rcvwnd": 1024,
    "nocomp": ${set_kcptun_nocomp}
}
EOF
    fi
}
install_kcptun_for_ss_ssr(){
    #if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
        if check_sys packageManager yum; then
            yum install -y epel-release
            yum install -y unzip openssl-devel gcc swig autoconf libtool libevent vim automake make psmisc curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel xmlto asciidoc pcre pcre-devel python python-devel python-setuptools udns-devel libev-devel mbedtls-devel
            if [ $? -gt 1 ]; then
                echo
                echo -e "${COLOR_RED}Install support packs failed!${COLOR_END}"
                exit 1
            fi
        elif check_sys packageManager apt; then
            if debianversion 7; then
                grep "jessie" /etc/apt/sources.list > /dev/null 2>&1
                if [ $? -ne 0 ] && [ -r /etc/apt/sources.list ]; then
                    echo "deb http://http.us.debian.org/debian jessie main" >> /etc/apt/sources.list
                fi
            fi
            apt-get -y update && apt-get -y install --no-install-recommends gettext curl wget vim unzip psmisc gcc swig autoconf automake make perl cpio build-essential libtool openssl libssl-dev zlib1g-dev xmlto asciidoc libpcre3 libpcre3-dev python python-dev python-pip python-m2crypto libev-dev libudns-dev
            if [ $? -gt 1 ]; then
                echo
                echo -e "${COLOR_RED}Install support packs failed!${COLOR_END}"
                exit 1
            fi
        fi
    #fi
    if [ ! -f /usr/lib/libsodium.a ] && [ ! -L /usr/local/lib/libsodium.so ]; then
        cd ${cur_dir}
        echo "+ Install libsodium for SS-Libev/SSR/KCPTUN"
        tar xzf ${libsodium_laster_ver}.tar.gz
        cd ${libsodium_laster_ver}
        ./configure --prefix=/usr && make && make install
        if [ $? -ne 0 ]; then
            install_cleanup
            echo -e "${COLOR_RED}libsodium install failed!${COLOR_END}"
            exit 1
        fi
        ldconfig
        #echo "/usr/lib" > /etc/ld.so.conf.d/local.conf
    fi
    if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ss_libev_installed_flag}" == "true" && "${ss_libev_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if check_sys packageManager yum; then
            echo "+ Install mbedtls for SS-Liber..."
            yum install -y mbedtls-devel
            if [ $? -ne 0 ]; then
                install_cleanup
                echo -e "${COLOR_RED}mbedtls install failed!${COLOR_END}"
                exit 1
            fi
        elif check_sys packageManager apt; then
            if [ ! -f /usr/lib/libmbedtls.a ]; then
                cd ${cur_dir}
                echo "+ Install mbedtls for SS-Liber..."
                tar xzf ${mbedtls_laster_ver}-gpl.tgz
                cd ${mbedtls_laster_ver}
                make SHARED=1 CFLAGS=-fPIC && make DESTDIR=/usr install
                if [ $? -ne 0 ]; then
                    install_cleanup
                    echo -e "${COLOR_RED}mbedtls install failed!${COLOR_END}"
                    exit 1
                fi
                ldconfig
            fi
        fi
        cd ${cur_dir}
        tar zxf ${shadowsocks_libev_ver}.tar.gz
        cd ${shadowsocks_libev_ver}
        ./configure
        make && make install
        if [ $? -eq 0 ]; then
            chmod +x /etc/init.d/shadowsocks
            if check_sys packageManager yum; then
                chkconfig --add shadowsocks
                chkconfig shadowsocks on
            elif check_sys packageManager apt; then
                update-rc.d -f shadowsocks defaults
            fi
            # Run shadowsocks in the background
            /etc/init.d/shadowsocks start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/shadowsocks ] && ln -s /etc/init.d/shadowsocks /usr/bin/shadowsocks
                echo -e "${COLOR_GREEN}Shadowsocks-libev start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}Shadowsocks-libev start failure!${COLOR_END}"
            fi
            ss_libev_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}Shadowsocks-libev install failed! Please visit ${contact_us} and contact.${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "true" && "${ssr_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        cd ${cur_dir}
        unzip -qo manyuser.zip
        mv shadowsocksr-manyuser/shadowsocks/ /usr/local/shadowsocksR
        if [ -x /usr/local/shadowsocksR/shadowsocks/server.py ] && [ -s /usr/local/shadowsocksR/shadowsocks/__init__.py ]; then
            chmod +x /etc/init.d/ssr
            if check_sys packageManager yum; then
                chkconfig --add ssr
                chkconfig ssr on
            elif check_sys packageManager apt; then
                update-rc.d -f ssr defaults
            fi
            /etc/init.d/ssr start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/ssr ] && ln -s /etc/init.d/ssr /usr/bin/ssr
                echo -e "${COLOR_GREEN}ShadowsocksR start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}ShadowsocksR start failure!${COLOR_END}"
            fi
            ssr_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}ShadowsocksR install failed! Please visit ${contact_us} and contact.${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "true" && "${kcptun_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        cd ${cur_dir}
        tar xzf ${kcptun_latest_file}
        [ ! -d /usr/local/kcptun ] && mkdir -p /usr/local/kcptun
        mv server_linux_${ARCHS} /usr/local/kcptun/kcptun
        rm -f ${kcptun_latest_file} client_linux_${ARCHS}
        chown root:root /usr/local/kcptun/*
        [ ! -x /usr/local/kcptun/kcptun ] && chmod 755 /usr/local/kcptun/kcptun
        /usr/local/kcptun/kcptun  --version
        if [ $? -eq 0 ]; then
            chmod +x /etc/init.d/kcptun
            if check_sys packageManager yum; then
                chkconfig --add kcptun
                chkconfig kcptun on
            elif check_sys packageManager apt; then
                update-rc.d -f kcptun defaults
            fi
            /etc/init.d/kcptun start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/kcptun ] && ln -s /etc/init.d/kcptun /usr/bin/kcptun
                echo -e "${COLOR_GREEN}kcptun start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}kcptun start failure!${COLOR_END}"
            fi
            kcptun_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}kcptun install failed! Please visit ${contact_us} and contact.${COLOR_END}"
            exit 1
        fi

    fi
    install_cleanup
}
# Firewall set
firewall_set(){
    if [ "${kcptun_install_flag}" == "true" ] || [ "${ss_libev_install_flag}" == "true" ] || [ "${ssr_install_flag}" == "true" ]; then
        echo "+ firewall set start..."
        firewall_set_flag="false"
        if centosversion 6; then
            /etc/init.d/iptables status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                if [ "${ss_libev_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_ss_libev_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${set_ss_libev_port} -j ACCEPT
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_ss_libev_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_ss_libev_port} has been set up."
                    fi
                fi
                if [ "${ssr_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_ssr_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${set_ssr_port} -j ACCEPT
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_ssr_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_ssr_port} has been set up."
                    fi
                fi
                if [ "${kcptun_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_kcptun_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_kcptun_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_kcptun_port} has been set up."
                    fi
                fi
                if [ "${firewall_set_flag}" == "true" ]; then
                    /etc/init.d/iptables save
                    /etc/init.d/iptables restart
                fi
            else
                echo "WARNING: iptables looks like shutdown or not installed, please manually set it if necessary."
            fi
        elif centosversion 7; then
            systemctl status firewalld > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                if [ "${ss_libev_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/tcp
                    firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${ssr_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/tcp
                    firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${kcptun_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_kcptun_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${firewall_set_flag}" == "true" ]; then
                    firewall-cmd --reload
                fi
            else
                echo "+ Firewalld looks like not running, try to start..."
                systemctl start firewalld
                if [ $? -eq 0 ]; then
                    if [ "${ss_libev_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/tcp
                        firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${ssr_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/tcp
                        firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${kcptun_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_kcptun_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${firewall_set_flag}" == "true" ]; then
                        firewall-cmd --reload
                    fi
                else
                    echo "WARNING: Try to start firewalld failed. please enable port manually if necessary."
                fi
            fi
        fi
        echo "+ firewall set completed..."
    fi
}
show_kcptun_for_ss_ssr(){
    echo
    if [ "${kcptun_install_flag}" == "true" ] || [ "${ss_libev_install_flag}" == "true" ] || [ "${ssr_install_flag}" == "true" ]; then
        SERVER_IP=$(get_ip)
        fun_clangcn
        echo "Congratulations, install completed!"
        echo -e "========================= Your Server Setting ========================="
        echo -e "Your Server IP: ${COLOR_GREEN}${SERVER_IP}${COLOR_END}"
    fi
    if [ "${kcptun_install_flag}" == "true" ]; then
        echo "-------------------- KCPTUN Setting --------------------"
        echo -e "Kcptun configure file     : ${COLOR_GREEN}${kcptun_config}${COLOR_END}"
        echo -e "Kcptun Server Port        : ${COLOR_GREEN}${set_kcptun_port}${COLOR_END}"
        echo -e "Kcptun Key                : ${COLOR_GREEN}${set_kcptun_pwd}${COLOR_END}"
        echo -e "Kcptun Crypt mode         : ${COLOR_GREEN}${set_kcptun_method}${COLOR_END}"
        echo -e "Kcptun Fast mode          : ${COLOR_GREEN}${set_kcptun_mode}${COLOR_END}"
        echo -e "Kcptun MTU                : ${COLOR_GREEN}${set_kcptun_mtu}${COLOR_END}"
        echo -e "Kcptun sndwnd             : ${COLOR_GREEN}1024${COLOR_END}"
        echo -e "Kcptun rcvwnd             : ${COLOR_GREEN}1024${COLOR_END}"
        echo -e "Kcptun compression        : ${COLOR_GREEN}${set_kcptun_compression}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "${COLOR_PINK}Kcptun config for SS/SSR/Phone:${COLOR_END}"
        echo -e "KCP Port      : ${COLOR_GREEN}${set_kcptun_port}${COLOR_END}"
        echo -e "KCP parameter : ${COLOR_GREEN}--crypt ${set_kcptun_method} --key ${set_kcptun_pwd} --mtu ${set_kcptun_mtu} --sndwnd 128 --rcvwnd 1024 --mode ${set_kcptun_mode}${show_kcptun_nocomp}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "Kcptun status manage: ${COLOR_PINK}/etc/init.d/kcptun${COLOR_END} {${COLOR_GREEN}start|stop|restart|status|config|version${COLOR_END}}"
        echo "=========================================================="
    fi
    echo
}
pre_install_kcptun_for_ss_ssr(){
    fire_check "clear"
    get_install_version
    Dispaly_Selection
    Press_Install
    Print_Sys_Info
    Disable_Selinux
    check_kcptun_for_ss_ssr_installed
    cd ${cur_dir}
    ###############################   KCPTUN   ###############################
    if [ "${kcptun_installed_flag}" == "false" ]; then
        echo
        echo "=========================================================="
        echo -e "${COLOR_PINK}Please input your KCPTUN setting:${COLOR_END}"
        echo
        def_kcptun_pwd="666666"
        echo "Please input password for kcptun"
        read -p "(Default password: ${def_kcptun_pwd}):" set_kcptun_pwd
        [ -z "${set_kcptun_pwd}" ] && set_kcptun_pwd="${def_kcptun_pwd}"
        echo
        echo "---------------------------------------"
        echo "kcptun password = ${set_kcptun_pwd}"
        echo "---------------------------------------"
        echo
        # Set kcptun port
        while true
        do
            def_kcptun_port="18989"
            echo -e "Please input port for kcptun [1-65535]"
            read -p "(Default port: ${def_kcptun_port}):" set_kcptun_port
            [ -z "$set_kcptun_port" ] && set_kcptun_port="${def_kcptun_port}"
            expr ${set_kcptun_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_kcptun_port} -ge 1 ] && [ ${set_kcptun_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "kcptun port = ${set_kcptun_port}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        if [ ! -z ${set_ss_libev_port} ]; then
            kcptun_target_port="${set_ss_libev_port}"
        elif [ ! -z ${set_ssr_port} ]; then
            kcptun_target_port="${set_ssr_port}"
        else
            while true
            do
                def_kcptun_target_port=""
                read -p "Please input kcptun Target Port for SS/SSR/Socks5 [1-65535]:" set_kcptun_target_port
                [ -z "$set_kcptun_target_port" ] && set_kcptun_target_port="${def_kcptun_target_port}"
                expr ${set_kcptun_target_port} + 0 &>/dev/null
                if [ $? -eq 0 ]; then
                    if [ ${set_kcptun_target_port} -ge 1 ] && [ ${set_kcptun_target_port} -le 65535 ]; then
                        echo
                        echo "---------------------------------------"
                        echo "kcptun target port = ${set_kcptun_target_port}"
                        echo "---------------------------------------"
                        echo
                        break
                    else
                        echo "Input error, please input correct number"
                    fi
                else
                    echo "Input error, please input correct number"
                fi
            done
            kcptun_target_port="${set_kcptun_target_port}"
        fi
        def_kcptun_method="aes"
        echo -e "Please select method for kcptun"
        echo "  1: aes (default)"
        echo "  2: aes-128"
        echo "  3: aes-192"
        echo "  4: salsa20"
        echo "  5: blowfish"
        echo "  6: twofish"
        echo "  7: cast5"
        echo "  8: 3des"
        echo "  9: tea"
        echo " 10: xtea"
        echo " 11: xor"
        read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_kcptun_method}]): " set_kcptun_method
        case "${set_kcptun_method}" in
            1|[aA][eE][sS])
                set_kcptun_method="aes"
                ;;
            2|[aA][eE][sS]-128)
                set_kcptun_method="aes-128"
                ;;
            3|[aA][eE][sS]-192)
                set_kcptun_method="aes-192"
                ;;
            4|[sS][aA][lL][sS][aA]20)
                set_kcptun_method="salsa20"
                ;;
            5|[bB][lL][oO][wW][fF][iI][sS][hH])
                set_kcptun_method="blowfish"
                ;;
            6|[tT][wW][oO][fF][iI][sS][hH])
                set_kcptun_method="twofish"
                ;;
            7|[cC][aA][sS][tT]5)
                set_kcptun_method="cast5"
                ;;
            8|3[dD][eE][sS])
                set_kcptun_method="3des"
                ;;
            9|[tT][eE][aA])
                set_kcptun_method="tea"
                ;;
            10|[xX][tT][eE][aA])
                set_kcptun_method="xtea"
                ;;
            11|[xX][oO][rR])
                set_kcptun_method="xor"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_kcptun_method="${def_kcptun_method}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "kcptun method: ${set_kcptun_method}"
        echo "---------------------------------------"
        echo
        def_kcptun_mode="fast2"
        echo -e "Please select fast mode for kcptun"
        echo "1: fast"
        echo "2: fast2 (default)"
        echo "3: fast3"
        echo "4: normal"
        read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_kcptun_mode}]): " set_kcptun_mode
        case "${set_kcptun_mode}" in
            1|[fF][aA][sS][tT])
                set_kcptun_mode="fast"
                ;;
            2|[fF][aA][sS][tT]2)
                set_kcptun_mode="fast2"
                ;;
            3|[fF][aA][sS][tT]3)
                set_kcptun_mode="fast3"
                ;;
            4|[nN][oO][rR][mM][aA][lL])
                set_kcptun_mode="normal"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_kcptun_mode="${def_kcptun_mode}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "kcptun mode: ${set_kcptun_mode}"
        echo "---------------------------------------"
        echo
        while true
        do
            def_kcptun_mtu="1350"
            echo -e "Please input MTU for kcptun [900-1400]"
            read -p "(Default mtu: ${def_kcptun_mtu}):" set_kcptun_mtu
            [ -z "$set_kcptun_mtu" ] && set_kcptun_mtu="${def_kcptun_mtu}"
            expr ${set_kcptun_mtu} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_kcptun_mtu} -ge 900 ] && [ ${set_kcptun_mtu} -le 1400 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "kcptun mtu = ${set_kcptun_mtu}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        def_kcptun_compression="enable"
        echo -e "Please select Compression for kcptun"
        echo "1: enable (default)"
        echo "2: disable"
        read -p "Enter your choice (1, 2 or exit. default [${def_kcptun_compression}]): " set_kcptun_compression
        case "${set_kcptun_compression}" in
            1|[yY]|[yY][eE][sS]|[tT][rR][uU][eE]|[eE][nN][aA][bB][lL][eE])
                set_kcptun_compression="enable"
                set_kcptun_nocomp="false"
                show_kcptun_nocomp=""
            ;;
            2|0|[nN]|[nN][oO]|[fF][aA][lL][sS][eE]|[dD][iI][sS][aA][bB][lL][eE])
                set_kcptun_compression="disable"
                set_kcptun_nocomp="true"
                show_kcptun_nocomp=" --nocomp"
            ;;
            *)
                set_kcptun_compression="enable"
                set_kcptun_nocomp="false"
                show_kcptun_nocomp=""
        esac
        echo
        echo "---------------------------------------"
        echo "kcptun compression: ${set_kcptun_compression}"
        echo "---------------------------------------"
        echo
        echo "=========================================================="
    elif [ "${kcptun_installed_flag}" == "true" ]; then
        echo
        echo -e "${COLOR_PINK}kcptun has been installed, nothing to do...${COLOR_END}"
        [ "${Install_Select}" == "3" ] && exit 0
        [ "${Install_Select}" == "4" ] && [ "${ss_libev_installed_flag}" == "true" ] && exit 0
        [ "${Install_Select}" == "5" ] && [ "${ssr_installed_flag}" == "true" ] && exit 0
    fi
    Press_Start
    get_latest_version
    down_kcptun_for_ss_ssr
    config_kcptun_for_ss_ssr
    install_kcptun_for_ss_ssr
    install_cleanup
    if check_sys packageManager yum; then
        firewall_set
    fi
    show_kcptun_for_ss_ssr
}
uninstall_kcptun_for_ss_ssr(){
    Get_Dist_Name
    fun_clangcn "clear"
    def_Uninstall_Select="1"
    echo -e "${COLOR_YELOW}You have 2 options for your kcptun/ss/ssr Uninstall${COLOR_END}"
    echo "1: Uninstall KCPTUN"
    echo "2: Exit,cancell uninstall"
    read -p "Enter your choice (1, 2, or exit. default [${def_Uninstall_Select}]): " Uninstall_Select
    case "${Uninstall_Select}" in
    1)
        echo
        echo -e "${COLOR_PINK}You will Uninstall KCPTUN${COLOR_END}"
        ;;
    2|[eE][xX][iI][tT])
        echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
        exit 1
        ;;
    *)
        echo
        echo -e "${COLOR_PINK}No input,default select <Exit,cancell uninstall>, shell exit now!${COLOR_END}"
        exit 1
    esac
    Press_Start
    check_kcptun_for_ss_ssr_installed
    if [ "${Uninstall_Select}" == "1" ]; then
        if [ "${kcptun_installed_flag}" == "true" ]; then
            /etc/init.d/kcptun status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                /etc/init.d/kcptun stop
            fi
            if check_sys packageManager yum; then
                chkconfig --del kcptun
            elif check_sys packageManager apt; then
                update-rc.d -f kcptun remove
            fi
            rm -f ${kcptun_config}
            rm -f /usr/bin/kcptun
            rm -f /etc/init.d/kcptun
            rm -f /var/log/kcptun.log
            rm -rf /usr/local/kcptun
            echo -e "${COLOR_GREEN}kcptun uninstall success!${COLOR_END}"
        else
            echo -e "${COLOR_GREEN}kcptun not install!${COLOR_END}"
        fi
    fi
}
configure_kcptun_for_ss_ssr(){
    if [ -f ${kcptun_config} ]; then
        echo -e "Kcptun config file: ${COLOR_GREEN}${kcptun_config}${COLOR_END}"
    fi
}

fun_set_text_color
# Initialization
clang_action=$1
clear
cur_dir=$(pwd)
fun_clangcn "clear"
Get_Dist_Name
Check_OS_support
pre_install_packs
shell_update
[  -z ${clang_action} ] && clang_action="install"
case "${clang_action}" in
[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii])
    pre_install_kcptun_for_ss_ssr 2>&1 | tee ${cur_dir}/ss-ssr-kcptun-install.log
    ;;
[Cc]|[Cc][Oo][Nn][Ff][Ii][Gg]|-[Cc]|--[Cc])
    configure_kcptun_for_ss_ssr
    ;;
[Uu][Nn]|[Uu][Nn][Ii][Nn][Ss][Tt][Aa][Ll][Ll]|[Uu][Nn]|-[Uu][Nn]|--[Uu][Nn])
    uninstall_kcptun_for_ss_ssr 2>&1 | tee ${cur_dir}/ss-ssr-kcptun-uninstall.log
    ;;
[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp])
    update_kcptun_for_ss_ssr 2>&1 | tee ${cur_dir}/ss-ssr-kcptun-update.log
    ;;
*)
    fire_check "clear"
    echo "Arguments error! [${clang_action}]"
    echo "Usage: `basename $0` {install|uninstall|update|config}"
    ;;
esac
