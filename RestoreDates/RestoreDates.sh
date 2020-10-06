#!/bin/bash

max() {
    printf "%s\n" "$@" | sort -g | tail -n1
}

echo "Restoring Dates..."

offset="0"
count=0

if [ $# -eq 1 ]; then
	if [ "$1" -eq "$1" ] 2>/dev/null; then
		offset="$1"
	else
		echo "-> Error: \"$1\" is not a valid offset number of hours"
		exit
	fi
fi

for f in ./*stitch*.png; do
    # Match out all blocks of numbers that are separated by 0 or more underscores
	time=$([[ $f =~ [0-9]+(_[0-9]+)* ]] && echo "${BASH_REMATCH//_}") 
	
    # Timestamps need to be 14 digits long here....
    if [[ $time != "" ]]; then
        if [ ${#time} -gt 14 ]; then
            time="${time:0:14}"
        fi

        if [ ${#time} -lt 14 ]; then
            amt=$[14 - ${#time}]
            leftovers=$(printf "%-${amt}s" "0")
            time="${time}${leftovers// /0}"
        fi

        if [ ${#time} -eq 14 ]; then
    		echo
    		
            # Year, Month, and Day can't have 0s as the lowest value, so max against 
            # lowest default value
 
            year=$(max "${time:0:4}" "1991")
            month=$(max "${time:4:2}" "01")
            day=$(max "${time:6:2}" "01")
            hour="${time:8:2}"
            minute="${time:10:2}"
            second="${time:12:2}"

    		time="${year}-${month}-${day} ${hour}:${minute}:${second}"
    		
    		echo $f
    		echo "-> before: $(stat -c %y $f)" 
    		
    		newTime="$(date -d "$(date -d "$time")+$offset hours" "+%Y%m%d%H%M.%S")"
    		touch -m -t $newTime $f

    		echo "-> after:  $(stat -c %y $f)"
    		count=$[count+1]
            
            continue
        fi
    fi
	
    echo "-> Error: File \"$f\" has bad timestamp in filename"
done

echo
echo "Finished: successfully restored dates for $count files"