#!/bin/bash
pwd=`pwd`
#i try to create file in the name of each
if [ ! -d "$pwd/under_track" ]
	then 
		mkdir "$pwd/under_track"
fi
paramarr=($@)

req_dir=$1

## running first time-all files didnt created
if [ ! -e "`pwd`/under_track/new_one.txt" ]
	then 
		if [ ! -d $req_dir ]
			then 
				echo "Must include valid path"  >&2
		else
			if [[ "`echo  -n $req_dir |tail -c1`" == "/" ]] ##if directory ends with / - than change it-to avoid double save in track_file
					then 
						req_dir=${req_dir::-1}	
			fi
			export name_of_file=$(echo "$req_dir" | tr '/' '+') ##switch each / in file name to +-make it legal
																			##if its the first time the script called with this directory																			## i will create its txt file and apend inside its ls -l
					echo "Welcome to the bigBrother"
					touch $pwd/under_track/new_one.dirs			#creating matching file for the dirs
					touch $pwd/under_track/new_one.files			#creating matching file  for the file
					touch $pwd/under_track/new_one.txt			#creating matching file  for the whole data
					touch $pwd/under_track/new_one_arguments
					
					touch $pwd/under_track/curr_tracked_dir.dirs								#creating files we will use later
					touch $pwd/under_track/curr_tracked_dir.files	
					touch $pwd/under_track/curr_tracked_dir.txt
					#insert the data 
					ls -l $req_dir >$pwd/under_track/new_one.txt	
					
					##every line start with the letter d - is a direction-insert its name(last field in line) to the dirs file(already sorted)
					grep ^[d] $pwd/under_track/new_one.txt | rev | cut -d " " -f1 | rev >$pwd/under_track/new_one.dirs
					#sort the file using additional file an then delete it-couldnt sort in place
					sort $pwd/under_track/new_one.dirs>$pwd/under_track/new1
					cat $pwd/under_track/new1>$pwd/under_track/new_one.dirs
					rm $pwd/under_track/new1
					
					##all other line dont start with the letter d - is a file-insert its name(last field in line) to the files file(already sorted)
					grep ^[^dt] $pwd/under_track/new_one.txt | rev | cut -d " " -f1 | rev>$pwd/under_track/new_one.files
					#sort the file using additional file an then delete it-couldnt sort in place
					sort $pwd/under_track/new_one.files>$pwd/under_track/new1
					cat $pwd/under_track/new1>$pwd/under_track/new_one.files
					rm $pwd/under_track/new1
					
					echo  ${paramarr[@]}>  $pwd/under_track/new_one_arguments
		fi	
		## running the script for a saved argument and direction
else 
		
			req_dir="`cat $pwd/under_track/new_one_arguments | cut -d " " -f1`"
			param="`cat $pwd/under_track/new_one_arguments | cut -d " " -f2-`"
			#echo $param
			#echo $param
			read -a paramarr <<< "$param"
			#echo ${#paramarr[@]}
			#echo ${paramarr[0]}
			#echo ${paramarr[0]}
			#echo ${paramarr[1]}
			#echo ${paramarr[2]}
			
			#echo ${#paramarr[@]}
			#echo $req_dir
			#insert the currently data 
			ls -l $req_dir>$pwd/under_track/curr_tracked_dir.txt 
			##sort the current file in place
			sort -o $pwd/under_track/curr_tracked_dir.txt  $pwd/under_track/curr_tracked_dir.txt 
			
			##every line start with the letter d - is a direction-insert its name(last field in line) to the current dirs file
			grep ^[d] $pwd/under_track/curr_tracked_dir.txt| rev | cut -d " " -f1 | rev >$pwd/under_track/curr_tracked_dir.dirs
			#sort the file using additional file an then delete it-couldnt sort in place
			sort $pwd/under_track/curr_tracked_dir.dirs>$pwd/under_track/new1
			cat $pwd/under_track/new1>$pwd/under_track/curr_tracked_dir.dirs
			rm $pwd/under_track/new1
			
			##all other line dont start with the letter d - is a file-insert its name(last field in line) to the current files file
			grep ^[^dt] $pwd/under_track/curr_tracked_dir.txt | rev | cut -d " " -f1 | rev>$pwd/under_track/curr_tracked_dir.files
			#sort the file using additional file an then delete it-couldnt sort in place
			sort $pwd/under_track/curr_tracked_dir.files>$pwd/under_track/new1
			cat $pwd/under_track/new1>$pwd/under_track/curr_tracked_dir.files
			rm $pwd/under_track/new1
			
			#####comprasions between files:#####
			
			#if a directory EXIST currently on req_dir and NOT EXIST on name_of_file.dirs- Folder added: file_name
			while read file_name
				do	
					A="`grep "^$file_name$" $pwd/under_track/new_one.dirs`"
					if [ ${#A}  -eq  0 ]
						then
							if [ ${#paramarr[@]} -ne 1 ]				#adding the parameter condition-if there are specific names to track
							then													#dont mind for those that arent tracked
								if [[ " ${paramarr[@]} " =~ " $file_name " ]]	
									then
										echo Folder added: $file_name >&1			#to stdout as requsted
								fi
							else
								echo Folder added: $file_name >&1			#to stdout as requsted
							fi
					fi
				done <$pwd/under_track/curr_tracked_dir.dirs
				
			#if a file EXIST currently on req_dir and NOT EXIST on name_of_file.files- File added: file_name
			while read file_name
				do	
					A="`grep "^$file_name$" $pwd/under_track/new_one.files`"
					if [ ${#A}  -eq  0 ]
						then
							if [ ${#paramarr[@]} -ne 1 ]				#adding the parameter condition-if there are specific names to track
							then													#dont mind for those that arent tracked
								if [[ " ${paramarr[@]} " =~ " $file_name " ]]	
									then
										echo File added: $file_name >&1			#to stdout as requsted
								fi
							else
								echo File added: $file_name >&1			#to stdout as requsted
							fi
					fi
				done <$pwd/under_track/curr_tracked_dir.files
				
			#if a directory NOT EXIST currently on req_dir and  EXIST on name_of_file.dirs- Folder deleted: file_name
			while read file_name
				do	
					A="`grep "^$file_name$" $pwd/under_track/curr_tracked_dir.dirs`"
					if [ ${#A}  -eq  0 ]
						then
							if [ ${#paramarr[@]} -ne 1 ]				#adding the parameter condition-if there are specific names to track
							then													#dont mind for those that arent tracked
								if [[ " ${paramarr[@]} " =~ " $file_name " ]]	
									then
										echo Folder deleted: $file_name >&2			#to stderr as requsted
								fi
							else
								echo Folder deleted: $file_name >&2			#to stderr as requsted
							fi
					fi
				done <$pwd/under_track/new_one.dirs	
				
			#if a file EXIST on name_of_file.files and NOT EXIST currently on req_dir - File deleted: file_name
			while read file_name
				do	
					A="`grep "^$file_name$" $pwd/under_track/curr_tracked_dir.files`"
					if [ ${#A}  -eq  0 ]
						then
							if [ ${#paramarr[@]} -ne 1 ]				#adding the parameter condition-if there are specific names to track
							then													#dont mind for those that arent Appear
								if [[ " ${paramarr[@]} " =~ " $file_name " ]]	
									then
										echo File deleted: $file_name >&2			#to stderr as requsted
								fi
							else
								echo File deleted: $file_name >&2			#to stderr as requsted
							fi
					fi
				done <$pwd/under_track/new_one.files			
			
			#Finally-update the data to the current skript-the same way we did first time
			ls -l $req_dir >$pwd/under_track/new_one.txt
			##every line start with the letter d - is a direction-insert its name(last field in line) to the dirs file(already sorted)
			grep ^[d] $pwd/under_track/new_one.txt | rev | cut -d " " -f1 | rev >$pwd/under_track/new_one.dirs
			#sort the file using additional file an then delete it-couldnt sort in place
			sort $pwd/under_track/new_one.dirs>$pwd/under_track/new1
			cat $pwd/under_track/new1>$pwd/under_track/new_one.dirs
			rm $pwd/under_track/new1
			
			##all other line dont start with the letter d - is a file-insert its name(last field in line) to the files file(already sorted)
			grep ^[^dt] $pwd/under_track/new_one.txt | rev | cut -d " " -f1 | rev>$pwd/under_track/new_one.files
			#sort the file using additional file an then delete it-couldnt sort in place
			sort $pwd/under_track/new_one.files>$pwd/under_track/new1
			cat $pwd/under_track/new1>$pwd/under_track/new_one.files
			rm $pwd/under_track/new1
			
