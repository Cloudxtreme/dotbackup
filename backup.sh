#!/bin/bash

#
#	CONFIG
#

# Define the dot-files and dot-directories to backup (omit the '.').
# This is relative to home (~/).
backup_dots=(zshrc zprofile zlogin zlogout zsh vimrc vim)

# Define the stuff you wish to exclude, either the file, directory 
# or wildcard files. (removes file from backup.)
backup_exclude=(zsh/zsh_history vim/backup/* vim/tmp/*)

#
#	/CONFIG
#



# This variable defines the directory to store this host's backup.
hostdir=$HOSTNAME

# If the backup dir doesn't exist, create it!
if [ ! -d ./$hostdir ] ; then
	mkdir ./$HOSTNAME
fi

# Define function for copying directories.
case `uname` in
	Darwin)
		dircpcmd="cp -r -n"
		;;
	Linux)
		dircpcmd="cp -r -u"
		;;
	*)
		dircpcmd="cp -r"
		;;
esac

# Backup every file that is in the array
for b in ${backup_dots[@]} ; do
	if [ -e ~/.$b ] ; then
		if [ -d ~/.$b ] ; then
			mkdir -p $(dirname ./$hostdir/$b)
			$($dircpcmd ~/.$b ./$hostdir/$b)
		elif [ -f ~/.$b ] ; then
			mkdir -p $(dirname ./$hostdir/$b)
			cat ~/.$b > ./$hostdir/$b
		else
			echo "Error backing up .$b"
		fi
	fi
done

# Delete the files in the backup folder we don't want
for e in ${backup_exclude[@]} ; do
	if [ $(ls ./$hostdir/$e 2> /dev/null | wc -l) -gt 1 ] ; then
		rm -r ./$hostdir/$e
	else	
		if [ -d ./$hostdir/$e ] ; then
			rm -r ./$hostdir/$e
		elif [ -f ./$hostdir/$e ] ; then
			rm ./$hostdir/$e
		else
			excluded=$e
		fi
	fi
done
