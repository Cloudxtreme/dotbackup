#!/bin/bash

#
#	CONFIG
#

# Define the dot-files and dot-directories to backup (omit the '.').
# This is relative to home (~/).
backup_dots=(zshrc zprofile zlogin zlogout zsh vimrc vim)

# Define the stuff you wish to exclude, either the file, directory 
# or wildcard files. (removes file from backup.)
backup_exclude=(zsh/zsh_history vim/backup/* vim/backup/.* vim/tmp/* vim/tmp/.*)

# Empty directories (omit the '.')
# Create the following directories when restoring
backup_empty=(vim/backup/ vim/tmp/)

# Should we back up to a git repository? (This just does a basic 
# add, commit, push).
git_backup=true

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

# Count variables
tb=${#backup_dots[@]}
cb=0
eb=0

# Backup every file that is in the array
echo "Backing up $hostdir ..."
for b in ${backup_dots[@]} ; do
	if [ -e ~/.$b ] ; then
		if [ -d ~/.$b ] ; then
			mkdir -p $(dirname ./$hostdir/$b)
			if [ -d ./$hostdir/$b ] ; then
				rm -r ./$hostdir/$b
			fi
			$($dircpcmd ~/.$b ./$hostdir/$b)
			let "cb++"
		elif [ -f ~/.$b ] ; then
			mkdir -p $(dirname ./$hostdir/$b)
			cat ~/.$b > ./$hostdir/$b
			let "cb++"
		else
			echo "Error backing up .$b"
			let "eb++"
		fi
	fi
done

echo "$cb items backed up. Total possible: $tb."
if [ $eb -gt 1 ] ; then
	echo "$eb items failed to backup."
fi

echo ""

# Count variables
ce=0
fe=0

# Delete the files in the backup folder we don't want
echo "Excluding files from backup ..."
for e in ${backup_exclude[@]} ; do
	if [ $(ls ./$hostdir/$e 2> /dev/null | wc -l) -gt 1 ] ; then
		rm -r ./$hostdir/$e 2> /dev/null
		let "ce++"
	else	
		if [ -d ./$hostdir/$e ] ; then
			rm -r ./$hostdir/$e
			let "ce++"
		elif [ -f ./$hostdir/$e ] ; then
			rm ./$hostdir/$e
			let "ce++"
		else
			let "fe++"
		fi
	fi
done

echo "$ce items excluded from backup."
if [ $fe -gt 1 ] ; then
	echo "$fe items not found in this backup."
fi

# Count variables
cg=0

# Create empty directories.
echo "Creating empty directories ..."
for g in ${backup_empty[@]} ; do
	mkdir -p ./$hostdir/$g
	echo 'Empty Folder' > ./$hostdir/$g/EMPTY
	let "cg++"
done

echo "$cg empty directories created."


echo ""
echo "Done!"
echo ""

# Backing up to git if requested in config.
if [ -d "./.git" ] && $git_backup ; then
	dtn=$(date +"%Y-%m-%d")
	echo "Backing up to remote git repository ..."
	git add .
	git commit -m "Backup of $hostdir; ($dtn)"
	git push --all
	echo "Done!"
fi
