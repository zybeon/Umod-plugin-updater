#!/bin/bash
# Author: Rodney Yates (VRPC)
                                                                                                                       
# To Do: Add blacklist to skip updating plugins
                                                                                                                       
function ProgressBar {
#credit: Teddy Skarin (fearside) https://github.com/fearside/ProgressBar/blob/master/progressbar.sh
 let _progress=(${1}*100/${2}*100)/100
 let _done=(${_progress}*4)/10
 let _left=40-$_done
 _done=$(printf "%${_done}s")
 _left=$(printf "%${_left}s")
 printf "\rProgress : [${_done// /#}${_left// /-}] ${_progress}%%"
}
                                                                                                                       
#UPDATE!!!!  Location to your umod (oxide) plugins.
FILES=/home/*/serverfiles/oxide/plugins/*.cs
                                                                                                                       
n_items=$(ls 2>/dev/null -Ubad1 -- $FILES | wc -l)
i=0
updated=0
url="https://umod.org/plugins/"
printf "%s - UMOD updater script.\n" "$(date +%F_%T)" |& tee -a updater.log
printf "Found $n_items umod (oxide) files to be processed.\n" |& tee -a updater.log
ProgressBar $i $n_items
                                                                                                                       
for f in $FILES
do
  #Download plugin to temp file. Umod web server does not have timestamping turned on so Last-Modified header is not available
  if [curl --fail --fail-early -o updater.temp $url$(basename $f) 1>> updater.log 2> /dev/null]
  then
    printf "$(date +%f_%T) - File download failed with error $?, exiting. Check logs\n" |& tee -a updater.log          
    exit 1
  fi
  #Check differences in downloaded plugin to plugin on disk
  diff -s <(cat updater.temp) <(cat $f) 1>> updater.log  2> /dev/null
  if [[ $? == "1" ]]
  then
    ((updated++))
    printf "Change detected, updating plugin $(basename $f).\n" &>> updater.log
    # Copy temp file of updated plugin
    if [mv updater.temp "$f" &>> updater.log]
        then
      printf "$(date +%f_%T) - File copy failed, exiting. Check logs\n" |& tee -a updater.log
      exit 1
    fi
  fi
  ((i++)) # increment progress
  ProgressBar $i $n_items #Update progress
  sleep 0.5 #Sleep to not spam the web server
done

printf "$(date +%f_%T) - Finished! Updated $updated plugins. Check updater.log for details.\n" |& tee -a updater.log
