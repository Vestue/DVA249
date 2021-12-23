add_direc(){
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

list_direc(){
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
delete_direc(){
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
view_direc(){
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
mod_direc(){
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