#!/bin/bash

#######################################################
##                                                   ##
 ##  Oscar Einarsson and Ragnar Winblad von Walter  ##
   ##                                              ##
    ##                GROUP 30                   ##
     #############################################

#Check if the program is run as root.
if [[ `id -u` -ne 0 ]]
then
    echo 'Please run the command with sudo.'
    exit
fi

######################
#       MAIN        #
#####################

_main() {
    # Setup the colors that are used by the printed menus.
    RED=`tput setaf 1`
    GREEN=`tput setaf 2`
    BLUE=`tput setaf 4`
    YELLOW=`tput setaf 6`
    reset=`tput sgr0`
    end='0'

    CONTINUE=1
    while [[ $CONTINUE -eq 1 ]]
    do
        _main_menu
        _choice_single
        case $INPUT in
            u)
                _user
                ;;
            g)
                _group
                ;;
            d)
                _directory
                ;;
            n)
                _network_menu
                ;;
            b)
                echo 'Exiting program… '
                CONTINUE=0
                ;;
            q)
                echo 'Exiting program… '
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
    echo -e "\n******************************************************"
    echo "--------------------SYSTEM MANAGER--------------------"
    echo "${RED}u${reset} Users"
    echo ""
    echo "${GREEN}d${reset} Directories"
    echo
    echo "${BLUE}g${reset} Groups"
    echo
    echo "${YELLOW}n${reset} Network"
    echo
}

######################
#       USER        #
####################

_user() {
    RUNUSR=1
    while [[ $RUNUSR -eq 1 ]]
    do
        _user_menu
        _choice_single
        case $INPUT in
            a)
                _user_create
                _hold
                ;;
            l)
                _user_list
                _hold
                ;;
            v)
                echo 'Which user do you want to see the properties of?'
                _user_attributes_list
                _hold
                ;;
            m)
                _user_attributes_change
                _hold
                ;;
            d)
                _user_remove
                _hold
                ;;
            b)
                RUNUSR=0
                ;;
            q)
                echo 'Exiting program.. '
                CONTINUE=0
                RUNUSR=0
                ;;
            *)
                echo 'Wrong input. Try again.'
                _hold
                ;;
        esac                
    done
}
_user_menu() {
    echo -e "\n******************************************************"
    echo '----------------------USER MENU-----------------------'
    echo "${RED}a${reset} - User Add       (Create a new user)"
    echo "${RED}l${reset} - User List      (List all login users"
    echo "${RED}v${reset} - User View      (View user properties"
    echo "${RED}m${reset} - User Modify    (Modify user properties)"
    echo "${RED}d${reset} - User Delete    (Delete a login user)"
}
_user_create() {
    echo "Enter full name of user: "
    _choice_multiple
    read FULLNAME
    
    echo "Enter username of user: "
    _choice_multiple
    read USERNAME
    
    echo "Enter password of user: "
    _choice_multiple
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
_user_list() {
    echo -e "${RED}Users: ${reset}\n"

    # Find the UID range for login-users in the system.
    MIN=`cat /etc/login.defs | grep UID_MIN | awk '{print $2}' | head -1`
    MAX=`cat /etc/login.defs | grep UID_MAX | awk '{print $2}' | head -1`

    # Find the users that are within the range.
    eval getent passwd | awk -v min="$MIN" -v max="$MAX" -F ":" '$3 >= min && $3 <= max {print $1}'
}
_user_attributes_list() {
    _user_ask_which
    read USERNAME

    ATTR=`getent passwd $USERNAME`
    RETVAL=$?
    if [[ $RETVAL -eq 0 ]]
    then
        echo -e "\n${RED}u${reset} - Username: $USERNAME" 

        PASSX=`echo $ATTR | awk -F ":" '{print $2}'`
        echo "${RED}p${reset} - Password: $PASSX"

        USERID=`echo $ATTR | awk -F ":" '{print $3}'`
        echo "${RED}i${reset} - User ID: $USERID"

        GROUPID=`echo $ATTR | awk -F ":" '{print $4}'`
        echo "${RED}g${reset} - Primary group ID: $GROUPID"

        COMMENT=`echo $ATTR | awk -F ":" '{print $5}'`
        echo "${RED}c${reset} - Comment: $COMMENT"

        HOMEDIR=`echo $ATTR | awk -F ":" '{print $6}'`
        echo "${RED}d${reset} - Directory: $HOMEDIR"

        SHELLDIR=`echo $ATTR | awk -F ":" '{print $7}'`
        echo "${RED}s${reset} - Shell: $SHELLDIR"

        #GROUPS=`groups $USERNAME | cut -d " " -f 3- | sed "s/ /,/g"`
        echo -en "\n${RED}Groups:${reset}"
        eval groups $USERNAME | cut -d " " -f 3- | sed "s/ /,/g"
    else
        echo "Can't find user!"
    fi
}
_user_attributes_change() {
    echo "Which user do you want to modify the properties of?"

    # Asks the user to input a username and then prints a list with the chosen users attributes.
    _user_attributes_list

    echo -e "\nWhich property do you want to modify?"
    _choice_single

    # Changing password triggers a special dialogue.
    if [[ $INPUT == "p" ]]
    then
        passwd $USERNAME &> /dev/null
        RETVAL=$?
        if [[ $RETVAL -eq 0 ]]
        then
            echo "Password updated successfully!"
        elif [[ $RETVAL -eq 10 ]]
        then
            echo "Password do not match. Try again."
        else
            echo "Failed to update password."
        fi
        return 0
    fi

    echo -e "\nWhat do you want to change it to?"
    _choice_multiple
    read NEWDATA

    case $INPUT in
        u)
            usermod -l $NEWDATA $USERNAME
            # Renames the homedirectory so that the user keeps the old files.
            mv /home/$USERNAME /home/$NEWDATA
            _user_attribute_success
            ;;
        i)
            usermod -u $NEWDATA $USERNAME
            _user_attribute_success
            ;;
        g)
            groupmod -g $NEWDATA $USERNAME
            _user_attribute_success
            ;;
        c)
            usermod -c $NEWDATA $USERNAME
            _user_attribute_success
            ;;
        d)
            usermod -md $NEWDATA $USERNAME
            _user_attribute_success
            ;;
        s)
            usermod -s $NEWDATA $USERNAME
            _user_attribute_success
            ;;
        b)
            return 1
            ;;
        q)
            echo 'Exiting program..'
            CONTINUE=0
            return 2
            ;;
        *)
            echo 'Invalid option.'
            _hold
            ;;
    esac
}
_user_attribute_success() {
    echo 'Field has been successfully changed!'
}
_user_remove() {
    _user_ask_which
    read USERNAME

    userdel -r $USERNAME &> /dev/null
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
_user_ask_which() {
    echo 'Enter username:'
    _choice_multiple
}

######################
#       DIRECTORY   #
####################

_directory() {
    RUNDIR=1
    while [[ $RUNDIR -eq 1 ]]
    do
        _directory_menu
        _choice_single
        case $INPUT in
            a) 
                _directory_add
                _hold
                ;;
            l)
                _directory_list
                _hold
                ;;
            v)
                _directory_view
                _hold
                ;;
            m)
                _directory_modify
                _hold
                ;;
            d)
                _directory_delete
                _hold
                ;;
            b)
                RUNDIR=0
                ;;
            q)
                echo 'Exiting program…'
                CONTINUE=0
                RUNDIR=0
                ;;
            *)
                echo 'Wrong input. Try again'
                _hold
                ;;
        esac
    done
}
_directory_menu() {
    echo -e "\n******************************************************"
    echo '--------------------DIRECTORY MENU--------------------'
    echo "${GREEN}a${reset} - Directory Add      (Creates a new directory)"
    echo "${GREEN}l${reset} - Directory List     (Lists all content inside of directory)" 
    echo "${GREEN}v${reset} - Directory View     (View directory properties)"
    echo "${GREEN}m${reset} - Directory Modify   (Modify directory properties)" 
    echo "${GREEN}d${reset} - Directory Delete   (Delete a directory)"
}
_directory_add(){
	echo -n "Enter directory name >"
	read DIRECTORYNAME
	NOSPACES=`echo $DIRECTORYNAME | sed 's/ /_/g'`
	mkdir $NOSPACES
	RETVAL=$?
	if [ $RETVAL ==  0 ]
	then
		echo "A directory named $NOSPACES has been added!"  
	else
		echo "Directory could not be created"
	fi
}
_directory_list(){
	direc=`ls -l | egrep "^d" | awk '{print $9}'`
	direcexist=0
	echo -n "Enter directory to list >"
	read SEARCH

	for i in $direc
	do
		if [ $i == $SEARCH ]
		then
			ls $i
			direcexist=1
		fi
	done
	if [ $direcexist == 0 ]
	then
		echo "There is no such directory"
	fi
}
_directory_delete(){
	echo -n "Enter directory to delete >"
	read DELETE

	rm -r $DELETE 2>Err.log

	RETVAL=$?

	if [ $RETVAL == 0 ]
	then
		echo "The directory $DELETE has been deleted"
	else
		echo "Directory could not be removed"
	fi
}
_directory_view(){
	alldirec=`ls -l | egrep "^d"`
	direcexist=0
	echo  "Enter directory"
	echo -n "Choice >"
	read DIRECTORY

	for i in $alldirec
	do
		if [ $DIRECTORY == $i ]
		then
			echo -n "1. Owner: "
			owner=`ls -l | grep "$DIRECTORY" | awk '{print $3}'`
			echo $owner
			echo -n "2. Groups: "
			ls -l | grep "$DIRECTORY" | awk '{print $4}'
			echo -n "3. GroupID: "
			id -g $owner
			echo -n "4. Permissions: "
			ls -l | grep "$DIRECTORY" | awk '{print $1}'
			echo -n "5. Sticky bit: "
			sticky=`ls -l | grep "$DIRECTORY" | awk '{print $1}' | tail -c 2`
        fi
		if [ $sticky == "t" ]
		then
			echo "Yes"
		else

			echo "No"
		fi
		echo -n "6. Last Modified: "
		ls -l | grep "$DIRECTORY" | awk '{print $6,$7,$8}'
		direcexist=1
	done

	if [ $direcexist == 0 ]
	then
		echo "There is no such directory"
	fi

	eval $1=$DIRECTORY
}
_directory_modify(){
	direcexist=0
	direcall=`ls -l | egrep "^d"`
	moddir=''
	echo "Which directory do you want to modify?"
	view_direc moddir

	for i in $direcall
	do
		if [ $moddir == $i ]
		then
			echo -e "\nWhich property do you want to modify?"
			echo -n "Choice >"
			read NUM
			if [ $NUM == "1" ]
			then
				_user_list
				echo -n "Enter new directory owner >"
				read OWN

				chown $OWN $moddir
			elif [ $NUM == "2" ]
			then
				_group_list
				echo -n "Enter new directory group >"
				read GRP
				chown :$GRP $moddir
			elif [ $NUM == "3" ]
			then
				echo -n "Enter new groupID >"
				read $NEWID
				groupmod -g $NEWID $owner
			elif [ $NUM == "4" ]
			then
				RUN=1
				while [[ $RUN -eq 1 ]]
				do
					echo -e "1. User\n2. Groups\n3. Others\n4. All\n 0. Exit\n\n"
					echo "Type 'w' for write, 'r' for read and 'x' for execute"
					echo "type - or + before the letters inorder to add or remove"
					echo "What permission do you want to edit?"
					echo -n "choice >"
					read PER

					if [ $PER == 1 ]
					then
						echo -n "User permissions >"
						read per1
						chmod u$per1 $moddir

					elif [ $PER == 2 ]
					then
						echo -n "Group permissions >"
						read per2
						chmod g$per2 $moddir

					elif [ $PER == 3 ]
					then
						echo -n "Others permission >"
						read per3
						chmod o$per3 $moddir

					elif [ $PER == 4 ]
					then
						echo -n "Permission for everyone >"
						read per4
						chmod a$per4 $moddir

					elif [ $PER == 0 ]
					then
						RUN=0

					else
					echo "Invalid input"
					fi
				done
			elif [ $NUM == "5" ]
			then
				echo "Press 1 for stickybit and 0 for regular"
				echo -n "choice >"
				read STICKY
				if [ $STICKY == 1 ]
				then
					chmod +t $moddir
				elif [ $STICKY == 0 ]
				then
					chmod -t $moddir
				else
					echo "Invalid input"
				fi
			else
			echo "Invalid input"
			fi
		direcexist=1
		fi
	done
}
if [$direcexist == 0]
then
	echo "There is no such directory"
fi

######################
#       GROUPS      #
####################

_group() {
    RUNGRP=1
    while [[ $RUNGRP -eq 1 ]]
    do
        _group_menu
        _choice_single
        case $INPUT in
            a)
                _group_create
                _hold
                ;;
            l) 
                _group_list
                _hold
                ;;
            v)
                _group_list_users_in_specific_group
                _hold
                ;;
            m)
                _group_modify
                ;;
            d)
                _group_remove
                _hold
                ;;            
            b)
                RUNGRP=0
                ;;
            q)
                echo “Exiting…”
                CONTINUE=0
                RUNGRP=0
                ;;
            *)
                echo “Wrong input. Try again”
                _hold
                ;;
        esac
    done
}
_group_menu() {
    echo -e "\n******************************************************"
    echo "---------------------GROUPS MENU----------------------"
    echo "${BLUE}a${reset} - Group Add     (Adds a new group)"
    echo "${BLUE}l${reset} - Group List    (List all groups (Non system))"
    echo "${BLUE}v${reset} - Group View    (Lists all users in a group)"
    echo "${BLUE}m${reset} - Group Modify  (Add/remove user from a group)"
    echo "${BLUE}d${reset} - Group delete  (Delete a group)"
}
_group_create() {
    _group_ask_which
    read NAME
    eval addgroup $NAME 2> /dev/null
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
_group_list() {
    echo -e "${BLUE}Groups: ${reset}\n"

    # Find the GID range for user made groups in the system.
    MIN=`cat /etc/login.defs | grep GID_MIN | awk '{print $2}' | head -1`
    MAX=`cat /etc/login.defs | grep GID_MAX | awk '{print $2}' | head -1`

    # Print groups within the range.
    eval getent group | awk -v min="$MIN" -v max="$MAX" -F ":" '$3 >= min && $3 <= max {print $1}'
}
_group_list_users_in_specific_group() {
    _group_ask_which
    read NAME

    # Test if the group exists.
    getent group $NAME &> /dev/null
    RETVAL=$?
    if [[ $RETVAL -eq 2 ]]
    then
        echo "Can't find group."
        return
    fi

    USERS=`getent group $NAME | awk -F ":" '{print $4}'`

    # Test if the group is a primary group.
    getent passwd $NAME &> /dev/null
    RETVAL=$?
    if [[ $RETVAL -eq 0 ]]
    then
        # The primary user of the primary group needs to be added
        # to the print of the members of the group.
        USERS="${NAME}, ${USERS}"
    fi
    echo "Group members: $USERS"
}
_group_modify() {
    RUNGRPMOD=1
    while [[ $RUNGRPMOD -eq 1 ]]
    do
        echo -e "Do you want to add or remove a user?\n"
        echo "a - Add user"
        echo "r - Remove user"
        _choice_single
        case $INPUT in
            a)
                _group_add_user
                ;;
            r)
                _group_remove_user
                ;;
            b)
                RUNGRPMOD=0
                ;;
            q)
                echo "Exiting.."
                CONTINUE=0
                RUNGRP=0
                RUNGRPMOD=0
                ;;
            *)
                echo "Invalid input. Try again."
                ;;
        esac
    done
}
_group_add_user() {
    echo 'Which group do you want to add a user to?'
    _group_ask_which
    read GROUPNAME

    # Check if group exists.
    getent group $GROUPNAME 1> /dev/null
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]
    then
        echo -e "\nCan't find group. Try again.\n"
        return
    fi

    echo -e "\nWhich user do you want to add to the group?"
    _user_ask_which
    read USERNAME

    # Check if user exists.
    getent passwd $USERNAME 1> /dev/null
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]
    then
        echo "Can't find user. Try again."
        return
    fi

    # Everything is good, add user to group.
    adduser $USERNAME $GROUPNAME &> /dev/null
    echo "$USERNAME has been added to $GROUPNAME!"
}
_group_remove_user() {
    echo 'Which group do you want to remove a user from?'
    _group_ask_which
    read GROUPNAME

    # Check if group exists.
    getent group $GROUPNAME 1> /dev/null
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]
    then
        echo "Can't find group. Try again."
        return
    fi

    echo -e "\nWhich user do you want to remove from the group?"
    _user_ask_which
    read USERNAME

    # Check if user exists.
    getent passwd $USERNAME 1> /dev/null
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]
    then
        echo "Can't find user. Try again."
        return
    fi

    # Everything is good, remove user from group.
    deluser $USERNAME $GROUPNAME &> /dev/null
    echo "$USERNAME has been removed from $GROUPNAME!"
}
_group_remove() {
    _group_ask_which
    read NAME

    # Check if group exists.
    getent group $NAME 1> /dev/null
    RETVAL=$?
    if [[ $RETVAL -eq 2 ]]
    then
        echo "Can't find group."
        return
    fi

    # Get the GID of the group, and min and max GID values for
    # user made groups in the system.
    GROUPID=`getent group $NAME | awk -F ":" '{print $3}'`
    MIN=`cat /etc/login.defs | grep GID_MIN | awk '{print $2}' | head -1`
    MAX=`cat /etc/login.defs | grep GID_MAX | awk '{print $2}' | head -1`

    # Check if the group is within the GID range of user created groups.
    if [[ $GROUPID -ge $MIN && $GROUPID -le $MAX ]]
    then
        groupdel $NAME &> /dev/null
        RETVAL=$?
        if [[ $RETVAL -eq 8 ]]
        then
            echo "The group is a primary group."
            echo "Are you sure you want to delete it?"
            echo "Enter [y] to confirm."
            _choice_single
            if [[ $INPUT == "y" ]]
            then
                groupdel -f $NAME
                echo "Primary group $NAME has been deleted."
            elif [[ $INPUT == "q" ]]
            then
                echo 'Exiting program..'
                CONTINUE=0
            else
                echo 'Exiting.. '
            fi
        else
            echo "Group $NAME has been deleted."
        fi
    else
        echo "$NAME is a systemgroup. It cannot be deleted through this program."
    fi
}
_group_ask_which() {
    echo 'Enter name of group:'
    _choice_multiple
}

######################
#       NETWORK     #
####################

_network_menu() {
    echo -e "\n******************************************************"
    echo "--------------------NETWORK MENU----------------------"

    echo -en "${YELLOW}Computer name: ${reset}"
    _network_pcname
    _network_interfaces
    _hold
}
_network_pcname() {
    NAME=`hostname`
    echo -en "$NAME\n"
}
_network_interfaces() {
    # Read all interfaces except loopback, lo.
    INTERFACES=`ip link show | awk '{print $2}' | awk 'NR%2==1' | sed 's/:/ /g' | awk 'NR!=1'`
    i=0

    # Loop through the interfaces and print the info of every interface by itself.
    for interface in $INTERFACES
    do
        i=$((i+1))
        echo -ne "\n${YELLOW}Interface: ${reset}"
        NAME=`echo $INTERFACES | cut -d ' ' -f $i`
        echo $NAME

        # Print ip-address if there is one in the interface.
        ADDRESS=`ip addr show $NAME | grep inet`
        RETVAL=$?
        if [[ $RETVAL -eq 0 ]]
        then
            ADDRESS=`ip addr show $NAME | grep inet | awk '{print $2}' | head -1`
            echo -n "${YELLOW}IP address: ${reset}"
            echo $ADDRESS
        fi

        # Print gateway if one is found.
        GATEWAY=`ip route | grep $NAME`
        RETVAL=$?
        if [[ $RETVAL -eq 0 ]]
        then
            echo -n "${YELLOW}Gateway: ${reset}"
            GATEWAY=`ip r | grep $NAME | tail -1 | awk '{print $3}'`
            echo $GATEWAY
        fi

        # Print MAC-address if one is found.
        MACADDRESS=`ip link show $NAME | grep link/ether`
        RETVAL=$?
        if [[ $RETVAL -eq 0 ]]
        then
            echo -n "${YELLOW}MAC: ${reset}"
            MACADDRESS=`ip link show $NAME | grep link/ether | awk '{print $2}'`
            echo $MACADDRESS
        fi

        # Print status with diffrent color depending on the status.
        echo -n "${YELLOW}Status: ${reset}"
        STATUS=`ip link show $NAME | awk '{print $9}'`
        if [[ $STATUS == "UP" ]]
        then
            echo "${GREEN}$STATUS${reset}"
        elif [[ $STATUS == "DOWN" ]]
        then
            echo "${RED}$STATUS${reset}"
        else
            echo $STATUS
        fi
    done
}

######################
#        INPUT      #
####################

_hold() {
    # Wait for user input before continuing to next step.
    echo "------------------------------------------------------"
    echo -en 'Press any key to continue..\n\n'
    read -sn1 INPUT
}
_choice_single() {
    # Let the user make a single choice and then instantly move to next step.
    echo "------------------------------------------------------"
    echo "(q - Quit, b - Back)"
    echo -en 'Enter choice: \n\n'
    read -sn1 INPUT
}
_choice_multiple() {
    # Let the user enter a full string.
    echo "------------------------------------------------------"
    echo -en 'Enter choice: \n\n'
}

# Main is called at the end, causing the order of the functions to not matter.
_main