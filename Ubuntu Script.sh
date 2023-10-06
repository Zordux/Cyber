#!/bin/bash
echo "PLEASE DO NOT RUN THIS ON YOUR PERSONAL PC"
echo "PLEASE DO NOT RUN THIS ON YOUR PERSONAL PC"
echo "PLEASE DO NOT RUN THIS ON YOUR PERSONAL PC"
sleep 3s
echo "MAKE SURE TO HAVE A TXT FILE NAMED users.txt INSIDE THE SAME DIR AS THE SCRIPT"
sleep 5s

mainScreen(){
echo ' ____             __                         ____          __                       __       '
echo '/\  _ \          /\ \                       /\  _ \       /\ \__         __        /\ \__    '
echo '\ \ \/\_\  __  __\ \ \____     __   _ __    \ \ \L\ \ __  \ \  _\  _ __ /\_\    ___\ \  _\   '
echo ' \ \ \/_/_/\ \/\ \\ \  __ \  / __ \/\  __\   \ \  __/ __ \ \ \ \/ /\  __\/\ \  / __ \ \ \/   '
echo '  \ \ \L\ \ \ \_\ \\ \ \L\ \/\  __/\ \ \/     \ \ \/\ \L\ \_\ \ \_\ \ \/ \ \ \/\ \L\ \ \ \_  '
echo '   \ \____/\/ ____ \\ \_ __/\ \____\\ \_\      \ \_\ \__/ \_\\ \__\\ \_\  \ \_\ \____/\ \__\ '
echo '    \/___/   /___/  \\/___/  \/____/ \/_/       \/_/\/__/\/_/ \/__/ \/_/   \/_/\/___/  \/__/ '
echo '               /\___/                                                                        '
echo '               \/__/                                                                         '
echo
echo 'Ubuntu CyberPatriot Script'
echo
echo 'By Roman, with blood sweat and tears'
echo ""
runner=$(whoami)
echo "Wellcome $runner"
    echo ' 1) Run auto script -BETA            2) List Media files -NOTDONE'
    echo ' 3) List Audio files -NOTDONE        4) List Picture files -NOTDONE'
read input
case $((input)) in
    1)
    clear
    autoscript
    ;;
    *)
    echo "not a option"
    clear
    mainScreen
    ;;
esac
}

autoscript(){
echo "Checking if system users are on file..."
sleep 2s
#setting system users into sysusers array and users from a list into ckusers
mapfile -t sysusers < <(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1)
mapfile -t ckusers < users.txt

not_found=()
#checking for users on system but not on list
for user in "${sysusers[@]}"; do
    if [[ " ${ckusers[*]} " == *" $user "* ]]; then
        echo "Match: $user"
    else
        not_found+=("$user")
        echo "Intruder: $user"
    fi
done
#delelteing user on system but not on list option
if [ ${#not_found[@]} -gt 0 ]; then
    for baduser in "${not_found[@]}"; do
        echo "$baduser was not in your list. Delete them? y/n"
        read input
        if [ "$input" = "y" ]; then
            sudo deluser "$baduser"
        fi
    done
else
echo no Intruders
fi

echo "Checking if file users are on the system..."
sleep 2s
#updateing system users list just in case
mapfile -t sysusers < <(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1)

missing_users=()

#Checking if users on list are on system
for user in "${ckusers[@]}"; do
    if [[ " ${sysusers[*]} " != *" $user "* ]]; then
        echo "Not on system: $user"
        missing_users+=("$user")
    fi
done
#add user on list to system
if [ ${#missing_users[@]} -gt 0 ]; then
    for listuser in "${missing_users[@]}"; do
        echo "$listuser was found in your list but not on the system. Add them? y/n"
        read input
        if [ "$input" = "y" ]; then
            sudo adduser "$listuser"
        fi
    done
else
echo all users are on system
fi
sleep 2s
clear
#updateing system users list just in case
mapfile -t sysusers < <(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1)

echo "Changing every users password except yours..."
echo whats your username?
read input
sleep 3s
#checks each user and changes there password except mains users
for user in "${sysusers[@]}"; do
    if [ "$user" == "$input" ]; then
        echo "Found you"
    else
        echo "Changing password for user: $user"
        echo "$user:thisismynewpassword" | sudo chpasswd
    fi
done

echo "Every users password was changed!"
sleep 2s
clear

echo "Looking for admins"
echo whats your username?
read input
sleep 2s
#finding all admins
sudoers_users=$(grep -E '^(%|[^#]+)\s+ALL=\(ALL:\) ALL' /etc/sudoers | awk '{print $1}' | tr -d ':')
sudo_group_users=$(grep '^sudo:' /etc/group | cut -d ':' -f 4)

all_admin_users="$sudoers_users $sudo_group_users"
admin_users=($(echo "$all_admin_users" | tr ',' '\n'))

#Asks if should be a admin
for admin_user in "${admin_users[@]}"; do
    if [ "$admin_user" == "$input" ]; then
     echo "Found  you!"
    else
     echo "Should $admin_user keep there admin? y/n"
     read input
     if [ "$input" == "n" ]; then
      sudo deluser "$admin_user" sudo
     fi
    fi
done

echo "Admin done"
sleep 2s
clear

echo "Checking groups"
while true 
do
    echo "Do you want to add a new group?"
    read input
    if [ "$input" == "y" ]; then
        echo "What is the group name?"
        read input 
        echo `sudo groupadd $input`
        echo "New groups $input made!!!"
        sleep 2s
        clear
    else
        break
    fi
done
while true 
do
    echo "Do you want to delete a group?"
    read input
    if [ "$input" == "y" ]; then
        echo "What is the group name?"
        read input 
        sudo groupdel $input
        echo "Group $input Deleted!!!"
        sleep 2s
        clear
    else
        break
    fi
done
while true 
do
    echo "Do you want to add a user to a group?"
    read input
    if [ "$input" == "y" ]; then
        echo "What is the group name?"
        read input 
        echo "What is the users name?"
        read username
        sudo gpasswd -a $username $input
        echo "Added $username to $input"
        sleep 2s
        clear
    else
        break
    fi
done
while true 
do
    echo "Do you want to remove a user from a group?"
    read input
    if [ "$input" == "y" ]; then
        echo "What is the group name?"
        read input 
        echo "What is the users name?"
        read username
        sudo gpasswd -d $username $input
        echo "Removed $username from $input"
        sleep 2s
        clear
    else
        break
    fi
done

echo "Groups done..."
sleep 2s
clear
echo "Turnning on firewall"
echo `sudo apt install ufw -y`
sudo ufw enable

echo "Firewall has been turned on!!!"
sleep 3s
clear

echo "Now go fix the system updates type y when your done"
read input

clear

echo "Now go fix firefox type y when your done"
read input

clear

echo "Running full updates"
echo `sudo apt install full-update -y && sudo apt upgrade -y`

clear

echo "Running ssh"
sudo systemctl start sshd.service
sudo systemctl start ssh.service

clear

echo "Permit Root Login is not done"
echo "Im not sure how to put text into a file useing in code"
#Im not sure how to put text into a file useing in code
sleep 2s
echo "Removing auto login and guest is not done"
echo "Im not sure how to put text into a file useing in code"
#Im not sure how to put text into a file useing in code
sleep 3s

clear

echo "Setting Auditd"
sleep 2s
echo `sudo apt install auditd -y`
echo `sudo auditctl -e 1`

echo "Auditd DONE"
sleep 2s

clear

echo "Installing anti virus software"

echo `sudo apt-get install rkhunter -y`
echo `rkhunter --update`
echo `rkhunter -c --sk`
echo `sudo apt-get install clamav -y`
echo `sudo freshclam`
echo `sudo clamscan –i –r --remove=yes `

echo "Anti virus DONE!!!"
sleep 3s

clear

echo "ALL DONE SCRIPT WILL END !!!"
sleep 4s
mainScreen
}

mainScreen