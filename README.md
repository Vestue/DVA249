# DVA249
Linux Projektuppgift

### TODO
1. Fix SUID and GUID counts in all-toggle. The current count function requires $1 to be "g" or "u" which it never will while in "a" mode.
- Fixed
3. Going back from the permissions toggle-menu causes the program to ask the user to enter another directory. It should just go back to the main directory function.
- Fixed
4. Make permission text align properly in modify directory menu. Add two whitespaces before "Permission" in front of USER and one space before "Permission" in front of GROUP.
- Fixed
5. Fix checking for "home=ls /home" in delete directory function.
- Done
6. Add clear before every print
- Done
7. Using big letter while adding groups prints an error, convert all big letter to small letter before adding group.
- Fixed
9. Big letters in username should also be converted to small letters and spaces to be converted to _.
- Fixed
11. Deleting a user does not delete the usergroup and also seems to not delete user directory.
- Fixed
13. All error prints should be redirected. All possible returnvalues should be properly handled separetely.
