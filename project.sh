#!/bin/bash
HOSTNAME=$(hostname)


# Color  Variables

green='\e[32m'
blue='\e[34m'
red='\e[31m'
clear='\e[0m'

ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}
ColorRed(){
    echo -ne $red$1$clear
}


# Users
function add_user() {
    echo ""
    echo -n "Enter the username: "
    read username

    echo -n "Enter the password: "
    read -s password

    sudo adduser "$username"
    echo ""
}

function delete_user() {
    echo ""
    echo -n "Enter the username: "
    read username

    sudo deluser "$username"
    echo ""
}

function show_users(){
    echo ""
    cut -d: -f1 /etc/passwd
    echo ""
}

function user_detail() {
    echo ""
    if ! dpkg-query -W -f='${Status}' finger &> /dev/null
    then 
        echo "Installing required pacage please wait" 
        sudo apt-get install finger nano &> /dev/null
        echo "Done"
        clear
    fi

    echo "Input username : "
    read uname
    finger $uname
    echo ""
}

# Groups

function show_groups() {
    echo ""
    groups
    echo ""
}

function add_group() {
    echo ""
    echo -n "Enter the groupname: "
    read groupname

    sudo addgroup $groupname
    echo ""
}

function add_group_gid() {

    echo ""
    echo -n "Enter the groupname: "
    read groupname
    echo -n "Enter the GID: "
    read gid

    sudo addgroup --gid $gid $groupname
    echo ""
}

function add_group_system() {
    echo ""
    echo -n "Enter the groupname: "
    read groupname

    sudo groupadd -r $groupname
    echo ""
}

function delete_group() {
    echo ""
    echo -n "Enter the groupname: "
    read groupname

    sudo groupdel $groupname
    echo "Group successfully deleted"
    echo ""
}

function adduser_group() {
    echo ""
    echo -n "Enter the groupname: "
    read groupname
    echo -n "Enter the username: "
    read username

    sudo usermod -a -G $usergroup $username  
    echo ""
}


# Network

function get_net_tools() {
    echo ""
    if ! dpkg-query -W -f='${Status}' net-tools &> /dev/null
    then 
        echo "Installing required pacage please wait" 
        sudo apt-get install net-tools nano &> /dev/null
        echo "Done"
        clear

    elif ! dpkg-query -W -f='${Status}' traceroute &> /dev/null
    then   
        echo "Installing required pacage please wait" 
        sudo apt install traceroute nano &> /dev/null
        echo "Done"
        clear

    elif ! dpkg-query -W -f='${Status}' speedtest-cli &> /dev/null
    then
        echo "Installing required pacage please wait" 
        sudo apt install speedtest-cli &> /dev/null 
        echo "Done"
        clear
    fi
    echo ""
}

function create_alert() {

    echo ""
    echo   "* * * * * command to be executed
- - - - -
| | | | |
| | | | ----- Day of week (0 - 7) (Sunday=0 or 7)
| | | ------- Month (1 - 12)
| | --------- Day of month (1 - 31)
| ----------- Hour (0 - 23)
------------- Minute (0 - 59)"
    echo "Minute : "
    read minute
    echo "Hour : "
    read hour
    echo "Day of month : "
    read daymonth
    echo "Month : "
    read month
    echo "Day of week : "
    read dayweek

    job="$minute $hour $daymonth $month $dayweek"
    echo -ne "
    $(ColorRed '1)') Host
    $(ColorRed '2)') Website
    "
    read a
            case $a in
                1) clear; echo "Input host address : "; read hostaddr; crontab -l | { cat; echo "$job bash /mnt/c/Users/Shadow/WSB/Linux/network_monitor.sh 1 $hostaddr >/dev/null 2>&1"; } | crontab -  ;main_menu ;;
                2) clear; echo "Input host address : "; read hostaddr; crontab -l | { cat; echo "$job bash /mnt/c/Users/Shadow/WSB/Linux/network_monitor.sh 2 $hostaddr >/dev/null 2>&1"; } | crontab -  ;main_menu ;; 
                *) echo -e $red"Wrong option."$clear; clear; main_menu;;
            esac

    crontab -l | { cat; echo "$job /mnt/c/Users/Shadow/WSB/Linux/network_monitor.sh"; } | crontab -
}

function delete_alert() {
    echo ""
    crontab -l 
    echo "Choose which one u want to delete :"
    echo ""
    read tempalert
    crontab -l | grep -v $tempalert  | crontab -
    main_menu
}

function show_cron_jobs() {
    echo -ne "
    $(ColorRed '1)') For current user
    $(ColorRed '2)') For other user
    "
    read a
            case $a in
                1) clear; crontab -l; network_menu ;;
                2) clear; echo "Input Username : "; read usrname; sudo crontab -u $usrname -l; network_menu  ;;
                *) echo -e $red"Wrong option."$clear; clear; main_menu;;
            esac
}

# System
function memory_check() {
    echo ""
	echo "Memory usage on ${server_name} is: "
	free -h
	echo ""
}

function cpu_check() {
    echo ""
	echo "CPU load on ${server_name} is: "
    echo ""
    top -i
	uptime
    echo ""
}


function kernel_check() {
    echo ""
	echo "Kernel version on ${server_name} is: "
	echo ""
	uname -r
    echo ""
}

function scan_network() {
    int_ip=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){2}')
    
    is_alive_ping() {
    ping -c 1 $1 > /dev/null
    [ $? -eq 0 ] && echo Node with IP: $i is up.
    }

    for i in $int_ip.{1..254} 
    do
    is_alive_ping $i & disown
    done

}

function change_hostname() {
    echo ""
    echo "Enter new hostname : "
    read new_host_name
    sudo hostname $new_host_name
}

function monitor() {
    echo ""

    # Hostname
    echo -e $green"Hostname :" $HOSTNAME
    OSSTR=$(cat /etc/os-release)
    echo -e $green$OSSTR   

    # Architecture
    architecture=$(uname -m)
    echo -e $green"Architecture :" $architecture

    # Kernel Release
    kernelrelease=$(uname -r)
    echo -e $green"Kernel Release :"  $kernelrelease

    # Internal IP
    internalip=$(hostname -I)
    echo -e $green"Internal IP :" $internalip

    # External IP
    externalip=$(dig +short myip.opendns.com @resolver1.opendns.com)
    echo -e $green"External IP :  "$externalip

    # DNS
    nameservers=$(cat /etc/resolv.conf | sed '1 d' | awk '{print $2}')
    echo -e $green"Name Servers :"  $nameservers 

    #  Logged In Users
    echo -e $green"Logged In users :" && cat /tmp/who  && who>/tmp/who && whoami

    # RAM and SWAP Usages
    free -h | grep -v + > /tmp/ramcache
    echo -e $green"Ram Usages :" 
    cat /tmp/ramcache | grep -v "Swap"
    echo -e $green"Swap Usages :" 
    cat /tmp/ramcache | grep -v "Mem"

    # Check Disk Usages
    df -h| grep 'Filesystem\|/dev/sda*' > /tmp/diskusage
    echo -e $green"Disk Usages :"  
    cat /tmp/diskusage

    # Check Load Average
    loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $10 $11 $12}')
    echo -e $green"Load Average :" $loadaverage

    # Check System Uptime
    tecuptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
    echo -e $green"System Uptime Days/(HH:MM) :" $tecuptime

    echo ""
}





main_menu() {
    echo -ne "
    Main Menu
    $(ColorGreen '1)') System information
    $(ColorGreen '2)') Users
    $(ColorGreen '3)') Network
    $(ColorGreen '4)') Groups
    $(ColorGreen '5)') Monitor
    $(ColorGreen '0)') Exit
    $(ColorBlue 'Choose an option:') "
            read a
            case $a in
                1) clear; system_menu ;;
                2) clear; user_menu ;; 
                3) clear; network_menu ;;
                4) clear; groups_menu ;;
                5) clear; monitor ; main_menu ;;
                0) exit 0 ;;
                *) echo -e $red"Wrong option."$clear; main_menu;;
            esac
} 

system_menu() {
    echo -ne "
    System Menu
    $(ColorGreen '1)') Memory usage
    $(ColorGreen '2)') CPU load
    $(ColorGreen '3)') Kernel version
    $(ColorGreen '4)') Change hostname
    $(ColorGreen '9)') Return
    $(ColorGreen '0)') Exit
    $(ColorBlue 'Choose an option:') "
            read a
            case $a in
                1) clear; memory_check ; system_menu ;;
                2) clear; cpu_check ; system_menu ;;
                3) clear; kernel_check ; system_menu ;;
                4) clear; change_hostname ; system_menu ;;
                9) clear; main_menu ;;
                0) exit 0 ;;
                *) echo -e $red"Wrong option."$clear; system_menu;;
            esac
}

user_menu() {
    echo -ne "
    User Menu
    $(ColorGreen '1)') Show users
    $(ColorGreen '2)') Add user
    $(ColorGreen '3)') Delete user
    $(ColorGreen '4)') Show user details
    $(ColorGreen '9)') Return
    $(ColorGreen '0)') Exit
    $(ColorBlue 'Choose an option:') "
            read a
            case $a in
                1) clear; show_users ; user_menu ;;
                2) clear; add_user ; user_menu ;;
                3) clear; delete_user ; user_menu ;;
                4) clear; user_detail ; user_menu ;;
                9) clear; main_menu ;;
                0) exit 0 ;;
                *) echo -e $red"Wrong option."$clear; user_menu;;
            esac   
}

network_menu() {
    get_net_tools
    echo -ne "
    Network Menu
    $(ColorGreen '1)') Scan Network
    $(ColorGreen '2)') Speedtest
    $(ColorGreen '3)') Create new alert
    $(ColorGreen '4)') Delete alert 
    $(ColorGreen '5)') Show crone jobs
    $(ColorGreen '6)') Statistics
    $(ColorGreen '9)') Return
    $(ColorGreen '0)') Exit
    $(ColorBlue 'Choose an option:') "
            read a
            case $a in
                1) clear; scan_network ; network_menu ;;
                2) clear; speedtest ; network_menu ;;
                3) clear; create_alert ;;
                4) clear; delete_alert ;;
                5) clear; show_cron_jobs ;;
                6) clear; netstat -s; echo "Routing table : "; netstat -r; network_menu ;;
                9) clear; main_menu ;;
                0) exit 0 ;;
                *) echo -e $red"Wrong option."; network_menu;;
            esac   
}


groups_menu() {
    echo -ne "
    User Group Menu
    $(ColorRed '1)') Show Groups
    $(ColorRed '2)') Add Group
    $(ColorRed '3)') Delete Group
    $(ColorRed '4)') Add system Group
    $(ColorRed '5)') Add group with specyfic GID
    $(ColorRed '6)') Add user to group
    $(ColorRed '9)') Return
    $(ColorBlue 'Choose an option:') "
            read a
            case $a in
                1) clear; show_groups ; groups_menu ;;
                2) clear; add_group ; groups_menu ;;
                3) clear; delete_group ; groups_menu ;;
                4) clear; add_group_system ; groups_menu ;;
                5) clear; add_group_gid ; groups_menu ;;
                6) clear; adduser_group; groups_menu ;;
                9) clear; main_menu ;;
                *) echo -e $red"Wrong option."$clear; groups_menu;;
            esac
}

# Call the main menu function
main_menu