#!/bin/bash

#
# loadlab.sh
# This routine is used to initialize the Jupyter notebooks used by this Hands on Lab
#
# Date: 2019-12-04
# Credits: IBM 2019, George Baklarz [baklarz@ca.ibm.com]
#

# Default repository for the lab taken from the environment variable DTE_LAB. If it is not set then use a default value

if ! [ -z "$DTE_GIT" ]
  then
    DTE_GIT=github.com/Db2-DTE-POC
fi

if ! [ -z "$DTE_LAB" ]
  then
    REPOSITORY=$DTE_LAB
  else
    REPOSITORY=db2v115
fi

# If you supply a parameter to the command then it will override the REPOSITORY value

if ! [ -z "$1" ]
  then
    REPOSITORY=$1
fi

if [ $REPOSITORY = none ]
  then
    exit 0
fi 

#
# Variables used to set up the Github copy location and the message files
#

NOTEBOOKDIR=~/notebooks
NOTEBOOKFILE=$NOTEBOOKDIR/empty
REFRESHFILE=$NOTEBOOKDIR/refreshed
LOGFILE=~/Documents/db2pot.log
GITHUB=git://$DTE_GIT/$REPOSITORY
ASKREFRESH=$NOTEBOOKDIR/db2pot-refresh.html
ASKLEGAL=$NOTEBOOKDIR/db2pot-legal.html
JUPYTERTOC=http://localhost:8888/notebooks/Table_of_Contents.ipynb

#
# Display status Message to start
#

(
echo "# Initializing System - Please wait"
sleep 2
echo "100"
) |
zenity 	--progress \
  	--title="System Initialization" \
	--text="Initializing System" \
	--percentage=0 \
	--auto-close \
	--auto-kill \
	--pulsate \
	2> /dev/null


#
# Run my profile to make sure I pick up the correct Anaconda libraries
#

export PATH=~/anaconda3/bin:~/anaconda3/condabin:$PATH

# If the "empty" file exists in the notebooks directory, the program will remove the
# directory and all of the contents, and refresh it with the latest files from the 
# Github repository. This should have been done at startup of the machine, but you never know.

current_Time=$(date +"%Y-%m-%d %H:%M:%S")

#
# All of the steps that are executed in this file are logged into the /Documents/db2pot.log file
#

printf "Date: ${current_Time}\n" > $LOGFILE

#
# Check to see if Jupyter notebook is running and shut it down and then restart it
#

PID=$(pgrep "jupyter")

(
printf ">>> Stopping Jupyter Notebook so we can recycle it\n" >> $LOGFILE
echo "# Stopping Jupyter Notebook Server"
if [ ! -z "$PID" ]; then
	jupyter notebook stop 8888 2>> $LOGFILE
fi
sleep 2
echo "100"
) |
zenity 	--progress \
  	--title="System Initialization" \
	--text="Stopping Jupyter Notebook Server" \
	--percentage=0 \
	--auto-close \
	--auto-kill \
	--pulsate \
	2> /dev/null

#
# Check if we need to initialize the notebook directory with all of the Github repostory
#

printf ">>> Checking if initial notebook directory needs to be created\n" >> $LOGFILE

if ! [ -d "$NOTEBOOKDIR" ]; then

	#
	# First time the notebook directory has been loaded
	#

	printf ">>> Starting initial notebook load\n" >> $LOGFILE

	(

	echo "66" 
	echo "# Copying Github repository to notebooks directory" 
	git clone $GITHUB $NOTEBOOKDIR &>> $LOGFILE

	echo "100" 
	) |
	zenity 	--progress \
	  	--title="System Initialization" \
  		--text="Removing notebooks directory" \
  		--percentage=33 \
  		--auto-close \
  		--auto-kill \
		--pulsate \
		2> /dev/null

	printf ">>> Notebook refresh attempted\n" >> $LOGFILE

else

	#
	# The notebook directory already exists. Ask if the user wants them refreshed
	#

	printf ">>> Notebooks already exist on this machine\n" >> $LOGFILE
 
	# Ask if you want the files refreshed

	printf ">>> Checking to see if notebook directory should be refreshed\n" >> $LOGFILE

	zenity --text-info \
         --width=800\
         --height=400\
         --title="IBM Digital Technical Engagement"\
         --html\
         --filename=$ASKREFRESH \
         2> /dev/null 
   
	answer=$?

  	if [ $answer -eq 0 ]; then

		printf ">>> Double-checking that you want to drop the directory\n" >> $LOGFILE

    		zenity --question\
           	--width=500\
           	--text="Please confirm that you are going to refresh the notebook directory"\
           	--title="IBM Digital Technical Engagement"\
           	--no-wrap\
           	--ok-label="Refresh Notebook Directory"\
           	--cancel-label="Cancel"\
           	2> /dev/null

     		answer=$?

     		if [ $answer -eq 0 ]; then
			printf ">>> Starting notebook refresh\n" >> $LOGFILE
			(
			rm -rf $NOTEBOOKDIR
			sleep 2

			echo "66" 
			echo "# Copying Github repository to notebooks directory" 
			git clone $GITHUB $NOTEBOOKDIR &>> $LOGFILE
			
			echo "100"
			) |
			zenity 	--progress \
			  	--title="System Initialization" \
		  		--text="Removing notebooks directory" \
		  		--percentage=33 \
		  		--auto-close \
		  		--auto-kill \
				--pulsate \
				2> /dev/null

			printf ">>> Notebook refresh attempted\n" >> $LOGFILE

		else
			printf ">>> Notebook refresh declined\n" >> $LOGFILE
		fi
     	else
		printf ">>> Notebook refresh declined\n" >> $LOGFILE
     	fi
fi

if ! [ -d "$NOTEBOOKDIR" ]; then	
	zenity --error \
       	       --width=350 \
               --height=50 \
               --title="System Initialization" \
               --text="Unable to find the Github repository: ${REPOSITORY}. Check if the Repository name is correct or if the network is available. \n\nTry:\n<tt>sudo service network-manager restart</tt>" \
               2> /dev/null
	printf ">>> Initial Notebook load failed\n" >> $LOGFILE
	exit 0
fi

(
printf ">>> Starting Jupyter Notebook server\n" >> $LOGFILE	
echo "# Starting Jupyter Notebook Server"

jupyter notebook --NotebookApp.token='' \
		 --NotebookApp.disable_check_xsrf='True' \
		 --notebook-dir=$NOTEBOOKDIR \
		 --ip='0.0.0.0' \
		 --port=8888 \
		 --no-browser \
		 --allow-root \
		 2> /dev/null &
sleep 2
echo "100"
) |
zenity 	--progress \
  	--title="System Initialization" \
	--text="Starting Jupyter Notebook Server" \
	--percentage=0 \
	--auto-close \
	--auto-kill \
	--pulsate \
	2> /dev/null

#
# The user must agree to the terms and conditions of using the proof of technology
#

printf ">>> Requesting input for agreeing to the Terms and Conditions of this proof of technology\n" >> $LOGFILE

zenity --text-info\
       --width=800\
       --height=650\
       --title="IBM Digital Technical Engagement"\
       --checkbox="I have read and agree to the terms and conditions"\
       --html\
       --filename=$ASKLEGAL \
       2> /dev/null

answer=$?

if [ $answer -eq 1 ]; then

	#
	# If you decline we just don't bring up the Jupyter notebook directory
	#

	printf ">>> User declined to agree to Terms and Conditions of the proof of technology\n" >> $LOGFILE
	exit 0
fi

printf ">>> User agreed to the Terms and Conditions of this proof of technology\n" >> $LOGFILE

#
# Start the browser and display the Table of Contents file
#

printf ">>> Starting the browser and pointing to the TOC\n" >> $LOGFILE
google-chrome $JUPYTERTOC &>/dev/null &

printf ">>> Initialization complete\n" >> $LOGFILE
