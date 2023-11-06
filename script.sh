#!/bin/bash

#Checks if the script was ran on sudo or root 
if [ "$EUID" -ne 0 ]
  then echo "Run script as root or sudo"
  exit
fi

#Checks if users.txt is in the same dir as the script
File="users.txt"
if [ ! -f "$File" ]; then  
  echo "$File does not exist. Please make the file and put all users you want to add and all users on your readme list(Make sure admins and main user are in there)"  
  exit
fi  

#Checks of dbus is on the system and if not then download it
if ! sudo apt list --installed | grep -q "dbus-x11"; then
  echo "dbus-x11 is not installed. Installing..."
  sudo apt-get install dbus-x11
fi

#Sets temp file for checking if the new gnome-terminal is done
fifo="/tmp/terminal_fifo"
clear
mainScreen(){
echo -e '\033[91;1m
██████╗  █████╗ ████████╗██████╗ ██╗ ██████╗ ████████╗     ██████╗ ██╗   ██╗ █████╗ ██████╗ ██████╗ 
██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██║██╔═══██╗╚══██╔══╝    ██╔════╝ ██║   ██║██╔══██╗██╔══██╗██╔══██╗
██████╔╝███████║   ██║   ██████╔╝██║██║   ██║   ██║       ██║  ███╗██║   ██║███████║██████╔╝██║  ██║
██╔═══╝ ██╔══██║   ██║   ██╔══██╗██║██║   ██║   ██║       ██║   ██║██║   ██║██╔══██║██╔══██╗██║  ██║
██║     ██║  ██║   ██║   ██║  ██║██║╚██████╔╝   ██║       ╚██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝
╚═╝     ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝    ╚═╝        ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝   
			            \e[37mUbuntu CyberPatriot Script
			 	        \e[37mVersion:\033[0m 2.0
			   	       \033[33;4mby Roman Lopez\033[0m

			      \e[97m[1]\e[94m Run auto script -BETA       
			      \e[97m[2]\e[94m FTP Config -NOTDONE
			      \e[97m[3]\e[94m SSH key Config -NOTDONE     
			      \e[97m[4]\e[94m Updates Config -NOTDONE
\e[32m
'
read -p "Number: " input
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
echo "Checking system for unauthorized users..."
sleep 2s

#Sets local system users into a array and users from the users list into another array
mapfile -t sysusers < <(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1)
mapfile -t ckusers < users.txt

not_found=()
#Checks for users that are on the local system but not on the users list
for user in "${sysusers[@]}"; do
    if [[ " ${ckusers[*]} " == *" $user "* ]]; then
        echo "Match: $user"
    else
        not_found+=("$user")
        echo "Intruder: $user"
    fi
done

#Asks to keep or remove a user that was found on the system but not in the users list
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

echo "Checking if users on users list are on the system..."
sleep 2s

#Updates the system users list
mapfile -t sysusers < <(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1)

missing_users=()

#Checks if users list users are on the system
for user in "${ckusers[@]}"; do
    if [[ " ${sysusers[*]} " != *" $user "* ]]; then
        echo "Not on system: $user"
        missing_users+=("$user")
    fi
done
#Asks to add a user that was found on the users list but not on the system
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
#Updates the system users list
mapfile -t sysusers < <(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1)

echo "Changing every users password except yours..."
echo whats your username?
read input
echo "What password do you want to give the users"
read password
sleep 3s

#Changes passwords for all users on the system except for the main users
for user in "${sysusers[@]}"; do
    if [ "$user" == "$input" ]; then
        echo "Found you"
    else
        echo "Changing password for user: $user"
        echo "$user:$password" | sudo chpasswd
        echo "Changed"
    fi
done

echo "Every users password was changed!"
sleep 2s
clear

echo "Looking for admins"
echo whats your username?
read input
sleep 2s

#Finds all admins on the system
sudoers_users=$(grep -E '^(%|[^#]+)\s+ALL=\(ALL:\) ALL' /etc/sudoers | awk '{print $1}' | tr -d ':')
sudo_group_users=$(grep '^sudo:' /etc/group | cut -d ':' -f 4)

all_admin_users="$sudoers_users $sudo_group_users"
admin_users=($(echo "$all_admin_users" | tr ',' '\n'))

#Asks if a user should be a admin
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

#Installing and turning on firewall
mkfifo "$fifo"
echo "Turnning on firewall"
gnome-terminal -- bash -c "sudo apt install ufw; sudo ufw enable; sleep 3; echo 'Done' > $fifo"
read < "$fifo"
echo "Firewall has been turned on!!!"
sleep 3s
clear

echo "Now go fix the system updates type y when your done"
read input
clear

echo "Now go fix firefox type y when your done"
read input
clear

mkfifo "$fifo"
#Installing updates
echo "Running full updates"
mkfifo "$fifo"
gnome-terminal -- bash -c "sudo apt-get update -y; sudo apt upgrade -y; sleep 3; echo 'Done' > $fifo"
read < "$fifo"
clear

mkfifo "$fifo"
#Turning ssh on
echo "Starting ssh"
gnome-terminal -- bash -c "sudo systemctl start sshd.serviceg; sudo systemctl start ssh.service; sleep 3; echo 'Done' > $fifo"
read < "$fifo"
clear

echo "Permit Root Login is not done"
echo "Removing auto login and guest is not done"
sleep 3s
clear

mkfifo "$fifo"
#Installing and setting auditd
echo "Setting Auditd"
sleep 2s
gnome-terminal -- bash -c "sudo apt install auditd -y; sudo auditctl -e 1; sleep 3; echo 'Done' > $fifo"
read < "$fifo"
echo "Auditd DONE"
sleep 2s
clear

mkfifo "$fifo"
#Installing and setting up libpam
echo "Setting libpam"
gnome-terminal -- bash -c "sudo apt-get install libpam-cracklib; sleep 3; echo 'Done' > $fifo"
read < "$fifo"

echo `sed -i 's/PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs`

echo `sed -i 's/PASS_MIN_DAYS.*/PASS_MIN_DAYS   10/' /etc/login.defs`

echo `sed -i 's/PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs`

echo "Libpam Done!"
sleep 2s
clear

mkfifo "$fifo"
#Installing and setting up anti virus software
echo "Installing anti virus software"
gnome-terminal -- bash -c "sudo apt-get install rkhunter -y; rkhunter --update; rkhunter -c --sk; sudo apt-get install clamav -y; sudo freshclam; sudo freshclam; sudo clamscan –i –r --remove=yes; sleep 3; echo 'Done' > $fifo"
read < "$fifo"
echo "Anti virus DONE!!!"
sleep 3s
clear

#End of script
echo "ALL DONE SCRIPT WILL END !!!"
sleep 4s
clear
mainScreen
}

mainScreen