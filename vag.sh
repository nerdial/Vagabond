#!/bin/bash
function portIsNumber () {
    regex='^[0-9]+([.][0-9]+)?$'
    if ! [[ $1 =~ $regex ]] ; then
        echo "error: Not a number" >&2; exit 1
    else
        return 1
    fi
}
function appExist () {
    type "$1" &> /dev/null ;
}

function installNginx () {
    nginx=stable
    add-apt-repository ppa:nginx/$nginx
    apt-get update
    apt-get install nginx -y
}

function installPHP () {
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
    add-apt-repository ppa:ondrej/php
    apt-get update
    apt-get install php7.2-fpm php7.2-cli php-7.2-zip php-7.2-mbstring php-7.2-dom -y
}

function installSoftwarePropertiesCommon () {
     apt-get install software-properties-common -y
}

defaultPort=8000
defaultHost='localhost'
if [ -z ${1+x} ]; then 
    host=$defaultHost
else 
    host=$1 
fi

if [ -z ${2+x} ]; then 
    port=$defaultPort
else 
    portIsNumber $2
    port=$2 
fi

if appExist add-apt-repository ; then
    echo "add-apt-repository is installed"
else
    installSoftwarePropertiesCommon    
fi

if appExist nginx ; then
    echo "nginx is installed"
else
    installNginx    
fi

if appExist php-fpm7.2 ; then
    echo "php-fpm is installed"
else
    installPHP    
fi

arrIN=(${PWD//// })
configName=${arrIN[-1]}

absoulteRootPath='{absoulteRootPath}'
applicationPort='{applicationPort}'
hostName='{hostName}'

modifiedPath="${PWD/////\\}"
cat /etc/vag/nginx.conf | sed "s|"$absoulteRootPath"|"$PWD"|g" | sed "s|"$applicationPort"|"$port"|g" | sed "s|"$hostName"|"$host"|g" > /etc/nginx/conf.d/$configName".conf"

if (( $(ps -ef | grep -v grep | grep php7.2-fpm | wc -l) > 0 )); then
    /usr/sbin/service php7.2-fpm restart
else
    /usr/sbin/service php7.2-fpm start
fi

if (( $(ps -ef | grep -v grep | grep nginx | wc -l) > 0 )); then
    /usr/sbin/nginx -s reload
else
    /usr/sbin/nginx
fi
urlPath="http://localhost:"$port"/"
python -mwebbrowser $urlPath


