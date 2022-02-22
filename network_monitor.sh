#!/bin/bash

function check_host() {

    sudo apt-get install ssmtp &> /dev/null
    sudo apt install ssmtp &> /dev/null
    if  ping -c 5 -W 5 "$hostip"
    then
    echo "$hostip is alive" &> /dev/null
    else
    echo "$hostip is  down !" | /usr/sbin/ssmtp @EMAIL 
    fi

}

function check_website() {

    sudo apt-get install ssmtp &> /dev/null
    sudo apt install ssmtp &> /dev/null
    if curl -I "http://$websiteip" --max-time 15 || curl -I "https://$websiteip" --max-time 15; 
    then
    echo "$websiteip alive and web site is up" &> /dev/null
    else
    echo "$websiteip offline or web server problem !" | /usr/sbin/ssmtp @EMAIL 
    fi

}


if [ $# -eq 0 ]
then
    echo "No arguments supplied" &> /dev/null
elif [[ $1 -eq 1 && -n "$2" ]]
then
    hostip=$2
    check_host;
elif [[ $1 -eq 2 && -n "$2" ]]
then
    websiteip=$2
    check_website;
fi
