#!/bin/bash

# Define where the backup file is, either hostname or argument
if [ ! $1 ] ; then
	hostdir=$HOSTNAME
else
	hostdir=$1
fi

# Define function for copying directories
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

# Check backups exist and if so restore them.
if [ -e ./$hostdir/ ] ; then
	for i in $(ls ./$hostdir/) ; do
		if [ -e ./$hostdir/$i ] ; then
			if [ -d ./$hostdir/$i ] ; then
				$($dircpcmd ./$hostdir/$i ~/.$i)
			elif [ -f ./$hostdir/$i ] ; then
				cat ./$hostdir/$i > ~/.$i
			else
				echo "Error restoring $i"
			fi
		fi
	done
else
	echo "No backup available for $hostdir"
fi
