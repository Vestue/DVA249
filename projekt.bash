#!/bin/bash

#Check if run as root
if [[ `id -u` -ne 0 ]]
then
    echo "Please run the command with sudo."
    exit
fi

_main() {
    CONTINUE=1
while [[ $CONTINUE -eq 1 ]]
do
_main_menu
INPUT=$?
    case $INPUT in
        1)
            _user
            ;;
        2)
            _group
            ;;
        3)
            _folder
            ;;
        4)
            _network
            ;;
        5)
            echo “Exiting…”
            CONTINUE=0
            ;;
        *)
            echo “Wrong input: $INPUT. Try again.”
            _hold
            ;;
    esac
done
}
_main_menu() {
    echo “¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤”
echo “                                System Manager 3000”
echo -e “¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤\n”

read INPUT
return $INPUT
}
_user_menu() {
    echo MENU
    
    read INPUT
    return $INPUT
}
_group_menu() {
    echo MENU

    read INPUT
    RETURN $INPUT
}
_folder_menu() {
    echo MENU

    read INPUT
    RETURN $INPUT
}
_network_menu() {
    echo MENU

    read INPUT
    return $INPUT
}
_user() {
    CONTINUE=1
    while [[ $CONTINUE -eq 1 ]]
    do
        _user_menu
        INPUT=$?
    
        case $INPUT in
            1)
                _user_list
                _hold
                ;;
            2)
                _user_create
                _hold
                ;;
            3)
                _user_remove
                _hold
                ;;
            4)
                echo "Which user do you want to see the properties of?"
                _user_attributes_list
                _hold
                ;;
            5)
                _user_attributes_change
                _hold
                ;;
            6)
                CONTINUE=0
                ;;
            *)
                echo “Wrong input. Try again.
                _hold
        esac                
    done
}
_user_list() {
    echo “Listing users.. “
    echo -e "(Please wait)\n"
    # Hitta vilken range UID som används för login-användare
    MIN=`cat /etc/login.defs | grep UID_MIN | awk '{print $2}' | head -1`
    MAX=`cat /etc/login.defs | grep UID_MAX | awk '{print $2}' | head -1`

    eval getent passwd {$MIN..$MAX} | cut -d: -f1 
}
_user_create() {
    echo "Enter full name of user: "
    echo -n “Choice >”
    read FULLNAME
    
    echo "Enter username of user: "
    echo -n “Choice >”
    read USERNAME
    
    echo "Enter password of user: "
    echo -n “Choice >”
    read -s PASSWORD
    
    useradd $USERNAME -c $FULLNAME -md /home/$USERNAME -s /bin/bash -p $PASSWORD
    RETVAL=$?
    if [[ $RETVAL -eq 0 ]]
    then
        echo "User $USERNAME successfully created!"
    elif [[ $RETVAL -eq 9 ]]
    then
        echo "User $USERNAME already exists!"
    else
        echo "Failed to add user."
    fi
}
_user_remove() {
    _user_ask_which
    read USERNAME

    userdel -r $USERNAME
    RETVAL=$?
    if [[ $RETVAL -eq 0 ]]
    then
        echo "User $USERNAME has been removed!"
    elif [[ $RETVAL -eq 6 ]]
    then
        echo "User $USERNAME does not exist."
    else
        echo "Failed to add user."
    fi
}
_user_attributes_list() {
    echo -e "\nEnter username: "
    _askif_exit
    echo -n "Choice >"
    read USERNAME

    if [[ $USERNAME -eq 0 ]]
    then
        return  1
    fi

    ATTR=`getent passwd $USERNAME`
    RETVAL=$?
    if [[ $RETVAL -eq 0 ]]
    then
        USERID=`echo $ATTR | awk -F ":" '{print $3}'`
        GROUPID=`echo $ATTR | awk -F ":" '{print $4}'`
        COMMENT=`echo $ATTR | awk -F ":" '{print $5}'`
        HOMEDIR=`echo $ATTR | awk -F ":" '{print $6}'`
        SHELLDIR=`echo $ATTR | awk -F ":" '{print $7}'`
        
        # Ger för tillfället en \n separerad lista på grupper, detta borde ändras till att separeras med kommatecken
        # Kan möjligtvis bytas ut mot att kalla _group_list istället sen

        #eval GROUPS=`cat /etc/group | grep $USERNAME | awk -F ":" '{print $1}'`
        GROUPS=`groups $USERNAME | cut -d " " -f 3-`

        echo -e "\n1. Username: $USERNAME" 
        echo "2. User ID: $USERID"
        echo "3. Primary group ID: $GROUPID"
        echo "4. Comment: $COMMENT"
        echo "5. Directory: $HOMEDIR"
        echo "6. Shell: $SHELLDIR"
        echo -e "\n. Groups: $GROUPS"
    else
        echo "Can't find user!"
    fi
    return $USERNAME
}
_user_attributes_change() {
    echo "Which user do you want to modify the properties of?"
    _user_attributes_list
    USERNAME=$?
    if [[ $USERNAME -eq 1 ]]
    then
        return  1
    fi

    echo -e "\nWhich property do you want to modify?"
    echo "Enter number of field: "
    echo -en "Choice >"
    read OPTION
    echo -e "\nWhat do you want to change it to?"
    read NEWDATA


    case $OPTION in
        1)
            usermod -l $NEWDATA $USERNAME
            # Döper om hemdirectoriet, detta kan möjligtvis behövas ändras 
            mv /home/$USERNAME /home/$NEWDATA
            _user_attribute_success
            ;;
        2)
            usermod -u $NEWDATA $USERNAME
            _user_attribute_success
            ;;
        3)
            groupmod -g $NEWDATA $USERNAME
            _user_attribute_success
            ;;
        4)
            usermod -c $NEWDATA $USERNAME
            _user_attribute_success
            ;;
        5)
            usermod -md $NEWDATA $USERNAME
            _user_attribute_success
            ;;
        6)
            usermod -s $NEWDATA $USERNAME
            _user_attribute_success
            ;;
        0)
            return 1
            ;;
        *)
            echo 'Invalid option.'
    esac
}
_user_attribute_success() {
    echo 'Field has been successfully changed!'
}
_user_ask_which() {
    echo 'Enter username:'
    echo -en "Choice >"
}
_group() {
    CONTINUE=1
    while [[ $CONTINUE -eq 1 ]]
    do
        _group_menu
        INPUT=$?
        
        case $INPUT in
            1) 
                _group_list
                _hold
                ;;
            2)
                _group_create
                _hold
                ;;
            3)
                _group_remove
                _hold
                ;;
            4)
                _group_list_users_in_specific_group
                _hold
                ;;
            5)
                _group_add_user
                _hold
                ;;
            6)
                _group_remove_user
                _hold
                ;;
            7)
                CONTINUE=0
                ;;
            *)
                echo “Wrong input. Try again”
                _hold
                ;;
        esac
    done
}
_group_list() {
    echo “Listing groups.. “
    echo -e "(Please wait)\n"
    MIN=`cat /etc/login.defs | grep GID_MIN | awk '{print $2}' | head -1`
    MAX=`cat /etc/login.defs | grep GID_MAX | awk '{print $2}' | head -1`
    eval getent group {$MIN..$MAX} | awk -F ":" '{print $1}'
}
_group_create() {
    _group_ask_which
    read NAME
    eval addgroup $NAME
    RETVAL=$?
    if [[ $RETVAL -eq 0 ]]
    then
        echo "Group $NAME has been created!"
    elif [[ $RETVAL -eq 1 ]]
    then
        echo "Group $NAME already exists."
    else
        echo 'Failed to create group.'
    fi
}
_group_remove() {
    _group_ask_which
    read NAME
    getent group $NAME &> /dev/null
    RETVAL=$?
    if [[ $RETVAL -eq 2 ]]
    then
        echo "Can't find group."
        return
    fi

    GROUPID=`getent group $NAME | awk -F ":" '{print $3}'`
    MIN=`cat /etc/login.defs | grep GID_MIN | awk '{print $2}' | head -1`
    MAX=`cat /etc/login.defs | grep GID_MAX | awk '{print $2}' | head -1`

    # Om gruppen är inom intervallet för användargrupper
    if [[ $GROUPID -ge $MIN -a $GROUPID -le $MAX ]]
    then
        groupdel $NAME &> /dev/null
        RETVAL=$?
        if [[ $RETVAL -eq 8 ]]
        then
            echo "The group is a primary group."
            echo "Are you sure you want to delete it?"
            echo "Enter [y] to confirm."
            echo -en "Choice >"
            read INPUT
            if [[ $INPUT == "y" ]]
            then
                groupdel -f $NAME
                echo "Primary group $NAME has been deleted."
            else
                echo 'Exiting.. '
            fi
        else
            echo "Group $NAME has been deleted."
        fi
    else
        echo "$NAME is a systemgroup. It cannot be deleted through this program."
}
_group_list_users_in_specific_group() {
    _group_ask_which
    read NAME
    getent group $NAME &> /dev/null
    RETVAL=$?
    if [[ $RETVAL -eq 2 ]]
    then
        echo "Can't find group."
        return
    fi

    USERS=`getent group $NAME | awk -F ":" '{print $4}'`

    # Testar om gruppen är en primärgrupp
    getent passwd $NAME $> /dev/null
    RETVAL=$?
    if [[ $RETVAL -eq 0 ]]
    then
        USERS="$NAME, $USERS"
    fi

    echo "Group members: $USERS"
}
_group_add_user() {
    echo 'Which group do you want to add a user to?'
    _group_ask_which
    read GROUPNAME
    getent group $GROUPNAME $> /dev/null
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]
    then
        echo "Can't find group. Try again."
        return
    fi

    echo -e "\nWhich user do you want to add to the group?"
    _user_ask_which
    read USERNAME
    getent passwd $USERNAME $> /dev/null
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]
    then
        echo "Can't find user. Try again."
        return
    fi

    adduser $USERNAME $GROUPNAME
    echo "$USERNAME has been added to $GROUPNAME!"
}
_group_remove_user() {
    echo 'Which group do you want to remove a user from?'
    _group_ask_which
    read GROUPNAME
    getent group $GROUPNAME $> /dev/null
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]
    then
        echo "Can't find group. Try again."
        return
    fi

    echo -e "\nWhich user do you want to remove from the group?"
    _user_ask_which
    read USERNAME
    getent passwd $USERNAME $> /dev/null
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]
    then
        echo "Can't find user. Try again."
        return
    fi

    deluser $USERNAME $GROUPNAME
    echo "$USERNAME has been removed from $GROUPNAME!"
}
_group_ask_which() {
    echo 'Enter name of group:'
    echo -en 'Choice >'
}
_folder() {
    CONTINUE=1
    while [[ $CONTINUE -eq 1 ]]
    do
        _folder_menu
        INPUT=$?
        case $INPUT in
            1) 
                _folder_list
                _hold
                ;;
            2)
                _folder_create
                _hold
                ;;
            3)
                _folder_remove
                _hold
                ;;
            4)
                _folder_attribute_list
                _hold
                ;;
            5)
                _folder_attribute_change
                _hold
                ;;
            6)
                CONTINUE=0
                ;;
            *)
                echo “Wrong input. Try again”
                _hold
                ;;
        esac
    done
}
_network() {
    CONTINUE=1
    while [[ $CONTINUE -eq 1 ]]
    do
        _network_menu
        INPUT=$?
        case $INPUT in
            1)
                _network_pcname
                ;;

            2)
                _network_interface_name
                ;;

            # De under kan behöva ändras för att hantera enskilda interfaces
            3)
                _network_ip
                ;;
            4)
                _network_mac
                ;;
            5)
                _network_gateway
                ;;
            6)
                _network_status
                ;;
            7)
                CONTINUE=0
                ;;
            *)
                echo "Invalid option. Try again"
                ;;
        esac
    done
}
_network_pcname() {
    NAME=`hostname`
    echo  “Name of computer: $NAME“
    _hold
}
_network_interface_name() {
    INTERFACES=`ip link show | awk '{print $2}' | awk 'NR%2==1' | sed “s/:/ /g” | awk 'NR!=1'`
    echo -e “Your network interfaces are:\n$INTERFACES”
    _hold
}
_network_ip() {
    
    IPADDRESS=`hostname -I | awk '{print $1}'`
    echo “IP-address: $IPADDRESS”
    _hold
}
_network_mac() {
    MACADDRESS=`ip link show | egrep “link/ether” | awk '{print $2}'`
    echo “MAC-address: $MACADDRESS”
    _hold
}
_network_gateway() {
    GATEWAY=`ip route | grep default | awk '{print $3}'`
    echo  “Gateway: $GATEWAY”
    _hold
}
_network_status() {    
    CONTINUE=1
    while [[ CONTINUE -eq 1 ]]
    do
        echo -e "Which network interface do you want to see the status of?\n(Enter [1] to list all networks.\n)"
        echo -n “Choice: “
        read INPUT
        
        if [[ $INPUT -eq 1 ]]
        then
            _name_interface_name
            _hold
        else
            CONTINUE=0
        fi
    done
    
    STATUS=`ip link show $INPUT | awk '{print $9}' | head -1`
    if [[ $STATUS == “UP” ]]
    then
        echo “$INPUT is up!”
    elif [[ $STATUS == “DOWN” ]]
    then
        echo “$INPUT is down!”
    else
        echo "Can't find network."
    fi
    _hold
}
_hold() {
    #Wait for user input before continuing to next step
    echo "---------------------------------------------"
    echo -en “Press any key to continue..”
    read -sn1
}
_askif_exit() {
    echo "(Enter [0] to exit.)"
}

# Ska vara längst ned
# Eftersom main-funktionen kallas längst ned spelar det ingen roll vilken ordning funktionerna placeras
_main
