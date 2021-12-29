_directory_menu() {
    echo -e "\n******************************************************"
    echo '--------------------DIRECTORY MENU--------------------'

    echo "${GREEN}a${reset} - Directory Add      (Creates a new directory)"
    echo "${GREEN}l${reset} - Directory List     (Lists all content inside of directory)" 
    echo "${GREEN}v${reset} - Directory View     (View directory properties)"
    echo "${GREEN}m${reset} - Directory Modify   (Modify directory properties)" 
    echo "${GREEN}d${reset} - Directory Delete   (Delete a directory)"
    _choice_single
}
_directory_add(){

	echo "Choose a directory create your folder in"
	_hold
	_directory_list
	echo -n "Enter directory name >"
	read DIRECTORYNAME
	NOSPACES=`echo $DIRECTORYNAME | sed 's/ /_/g'`
	mkdir $NOSPACES
	RETVAL=$?
	if [ $RETVAL ==  0 ]
	then
		echo -e "\nA directory named $NOSPACES has been added!"  
	else
		echo "Directory could not be created"
	fi
	cd $currentDir
}
_directory_list(){
	direcexist=0
	go=0
	currentDir=`pwd`
	while [ $go == "0" ]
	do
	echo "------------------------------------------------------"
	echo -e "\nCurrent Directory contains: "
	direc=`ls -l |  awk '{print $9}' | sed "s/ /\n/g"`
	echo "$direc"
	echo -e "\n------------------------------------------------------"
	echo -n "Current Directory: "
	pwd
	echo "------------------------------------------------------"
	echo -e "(b - Go back to previous directory, q - quit, or enter the directory you want to enter)"
	echo -n "Choice >"
	read SEARCH

	if [ $SEARCH == "b" ]
	then	
	cd ..
	elif [ $SEARCH == "q" ]
	then
	go=1
	else
	cd $SEARCH

	fi
	done
}
_directory_delete(){

	echo "Choose directory in which you want to delete a folder"
	_hold
	_directory_list
	echo -n "Enter directory to delete >"
	read DELETE

	rm -r $DELETE 2>/dev/null

	RETVAL=$?

	if [ $RETVAL == 0 ]
	then
		echo "The directory $DELETE has been deleted"
	else
		echo "Directory could not be removed"
	fi
cd $currentDir
}
_directory_view(){
	direcexist=0


	echo "Choose directory to view properties of folder in "
	_hold
	_directory_list
	echo  "Enter directory"
	echo -n "Choice >"
	read DIRECTORY
	alldirec=`ls -l | egrep "^d"`
	for i in $alldirec
	do
		if [ $DIRECTORY == $i ]
		then
			echo -n "1. Owner: "
			owner=`ls -l | grep "$DIRECTORY" | awk '{print $3}'`
			echo $owner
			echo -n "2. Group: "
			group=`ls -l | grep "$DIRECTORY" | awk '{print $4}'`
			id=`cat /etc/group | egrep "^$group" | sed "s/:/ /g" | awk '{print $3}'`
			echo "$group($id)"
			echo -n -e "3. Permissions:\n"
			userP=`getfacl $DIRECTORY | egrep "^u" | sed "s/:/ /g" | awk '{print $2}'`
			grpP=`getfacl $DIRECTORY | egrep "^g" | sed "s/:/ /g" | awk '{print $2}'`
			other=`getfacl $DIRECTORY | egrep "^o" | sed "s/:/ /g" | awk '{print $2}'`
				if [ $userP == "r--" ]
				then
				echo -e "User Permission: Read only"
				elif [ $userP == "rw-" ]
				then
				echo -e "User Permission: Read and Write"
				elif [ $userP == "rwx" ]
				then
				echo -e "User Permission: Read, Write and Execute"
				elif [ $userP == "-w-" ]
				then
				echo -e "User Permission: Write only"
				elif [ $userP == "-wx" ]
				then
				echo -e "User Permission: Write and Execute"
				elif [ $userP == "r-x" ]
				then
				echo -e "User Permission: Read and Execute"
				elif [ $userP == "--x" ]
				then
				echo -e "User Permission: Execute Only"
				else
				echo -e "User has no permissions"
				fi

				if [ $grpP == "r--" ]
				then
				echo -e "Group Permission: Read only"
				elif [ $grpP == "rw-" ]
				then
				echo -e "Group Permission: Read and Write"
				elif [ $grpP == "rwx" ]
				then
				echo -e "Group Permission: Read, Write and Execute"
				elif [ $grpP == "-w-" ]
				then
				echo -e "Group Permission: Write only"
				elif [ $grpP == "-wx" ]
				then
				echo -e "Group Permission: Write and Execute"
				elif [ $grpP == "r-x" ]
				then
				echo -e "Group Permission: Read and Execute"
				elif [ $grpP == "--x" ]
				then
				echo -e "Group Permission: Execute Only"
				else echo -e "Group has no permissions"
				fi

				if [ $other == "r--" ]
				then
				echo -e "Others Permission: Read only"
				elif [ $other == "rw-" ]
				then
				echo -e "Others Permission: Read and Write"
				elif [ $other == "rwx" ]
				then
				echo -e "Others Permission: Read, Write and Execute"
				elif [ $other == "-w-" ]
				then
				echo -e "Others Permission: Write only"
				elif [ $other == "-wx" ]
				then
				echo -e "Others Permission: Write and Execute"
				elif [ $other == "r-x" ]
				then
				echo -e "Others Permission: Read and Execute"
				elif [ $other == "--x" ]
				then
				echo -e "Others Permission: Execute Only"
				else echo -e "Others has no permissions"
				fi
				
			echo -n "4. Sticky bit: "
			sticky=`ls -l | grep "$DIRECTORY" | awk '{print $1}' | tail -c 2`

		if [ $sticky == "t" ]
		then
			echo "Yes"
		else

			echo "No"

		fi
		echo -n "5. Last Opened: "
		ls -l | grep "$DIRECTORY" | awk '{print $6,$7,$8}'
		direcexist=1
	fi
	done

	if [ $direcexist == 0 ]
	then
		echo "There is no such directory"
	fi

	eval $1=$DIRECTORY 2>/dev/null 

}
_directory_modify(){
	direcexist=0
	moddir=''
	echo "Which directory do you want to modify?"
	_directory_view moddir
	direcall=`ls -l | egrep "^d"`
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
				RUN=1
				while [[ $RUN -eq 1 ]]
				do
					echo -e "u. User\ng. Groups\no. Others\na. All\nq. Exit\n\n"
					echo "What permission do you want to edit?"
					echo -n "choice >"
					read PER

					if [ $PER == "u" ]
					then
						
						
						echo "1. User can only Read"
						echo "2. User can Read and Write"
						echo "3. User can only Write"
						echo "4. User can Write and Execute"
						echo "5. User can only Execute"
						echo "6. User can Read and Execute"
						echo "7. User can Read, Write and Execute"
						echo -n "Choice >"
						read usrper
						chmod u-wrx $moddir
						if [ $usrper == "1" ]
						then
						chmod u+r $moddir
						
						elif [ $usrper == "2" ]
						then
						chmod u+rw $moddir

						elif [ $usrper == "3" ]
						then
						chmod u+w $moddir

						elif [ $usrper == "4" ]
						then
						chmod u+wx $moddir

						elif [ $usrper == "5" ]
						then
						chmod u+x $moddir

						elif [ $usrper == "6" ]
						then
						chmod u+rx $moddir

						elif [ $usrper == "7" ]
						then
						chmod u+rwx $moddir

						else
						echo "Invalid input"
						fi



					elif [ $PER == "g" ]
					then
						echo "1. Group can only Read"
						echo "2. Group can Read and Write"
						echo "3. Group can only Write"
						echo "4. Group can Write and Execute"
						echo "5. Group can only Execute"
						echo "6. Group can Read and Execute"
						echo "7. Group can Read, Write and Execute"
						echo -n "Choice >"
						read grpper
						chmod g-wrx $moddir
						if [ $grpper == "1" ]
						then
						chmod g+r $moddir
						
						elif [ $grpper == "2" ]
						then
						chmod g+rw $moddir

						elif [ $grpper == "3" ]
						then
						chmod g+w $moddir

						elif [ $grpper == "4" ]
						then
						chmod g+wx $moddir

						elif [ $grpper == "5" ]
						then
						chmod g+x $moddir

						elif [ $grpper == "6" ]
						then
						chmod g+rx $moddir

						elif [ $grpper == "7" ]
						then
						chmod g+rwx $moddir

						else
						echo "Invalid input"
						fi

					elif [ $PER == "o" ]
					then
						echo "1. Others can only Read"
						echo "2. Others can Read and Write"
						echo "3. Others can only Write"
						echo "4. Others can Write and Execute"
						echo "5. Others can only Execute"
						echo "6. Others can Read and Execute"
						echo "7. Others can Read, Write and Execute"
						echo -n "Choice >"
						read other
						chmod o-wrx $moddir
						if [ $other == "1" ]
						then
						chmod o+r $moddir
						
						elif [ $other == "2" ]
						then
						chmod o+rw $moddir

						elif [ $other == "3" ]
						then
						chmod o+w $moddir

						elif [ $other == "4" ]
						then
						chmod o+wx $moddir

						elif [ $other == "5" ]
						then
						chmod o+x $moddir

						elif [ $other == "6" ]
						then
						chmod o+rx $moddir

						elif [ $other == "7" ]
						then
						chmod o+rwx $moddir

						else
						echo "Invalid input"
						fi

					elif [ $PER == "a" ]
					then
						echo "1. Everyone can only Read"
						echo "2. Everyone can Read and Write"
						echo "3. Everyone can only Write"
						echo "4. Everyone can Write and Execute"
						echo "5. Everyone can only Execute"
						echo "6. Everyone can Read and Execute"
						echo "7. Everyone can Read, Write and Execute"
						echo -n "Choice >"
						read all
						chmod a-wrx $moddir
						if [ $all == "1" ]
						then
						chmod a+r $moddir
						
						elif [ $all == "2" ]
						then
						chmod a+rw $moddir

						elif [ $all == "3" ]
						then
						chmod a+w $moddir

						elif [ $all == "4" ]
						then
						chmod a+wx $moddir

						elif [ $all == "5" ]
						then
						chmod a+x $moddir

						elif [ $all == "6" ]
						then
						chmod a+rx $moddir

						elif [ $all == "7" ]
						then
						chmod a+rwx $moddir

						else
						echo "Invalid input"
						fi

					elif [ $PER == "q" ]
					then
						RUN=0

					else
					echo "Invalid input"
					fi
				done
			elif [ $NUM == "4" ]
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
	cd $currentDir
}
if [ $direcexist == 0 ]
then
	echo "There is no such directory"
fi
