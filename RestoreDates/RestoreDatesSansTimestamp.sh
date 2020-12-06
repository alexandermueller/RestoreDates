#!/bin/bash

DAY_LENGTH_SECONDS=86400

max() {
    printf "%s\n" "$@" | sort -g | tail -n1
}

getExifDateTaken() {
    if [ $# -eq 1 ]; then
        echo $(date -d "$(exiftool -DateTimeOriginal -s3 "$1" -d "%Y-%m-%d %H:%M:%S")" +%s)
    else
        echo "No argument given!"
    fi
}

formattedDateFromTimestamp() {
    if [ $# -eq 1 ]; then
        echo $(date -d @$1)
    else
        echo "No argument given!"
    fi 
}

exifDateFromTimestamp() {
    if [ $# -eq 1 ]; then
        echo $(date -d @$1 "+%Y:%m:%d %H:%M:%S") 
    else
        echo "No argument given!"
    fi 
}

echo "Restoring Dates Without Proper Timestamps..."

lastTimeStamp=0
count=0

# Grab first file in folder's timestamp and 
# get the last midnight timestamp from it
for f in ./[a-zA-Z0-9_.]*; do
    if [[ "$f" == *"./*"* ]] || [[ -d "$f" ]]; then
        continue
    fi

    echo "$f"

    if [[ "$f" != *"stitch"* ]]; then
        lastTimeStamp=$(getExifDateTaken "$f")
        rounded=$[lastTimeStamp - lastTimeStamp % DAY_LENGTH_SECONDS]
        echo "->       Earliest timestamp found: $lastTimeStamp ($(formattedDateFromTimestamp $lastTimeStamp))"
        echo "-> Rounding down to last midnight: $rounded ($(formattedDateFromTimestamp $rounded))"
        lastTimeStamp=$rounded
        break
    fi
done

if [ "$lastTimeStamp" -eq "0" ]; then
    echo "-> Error: No image timestamp found."
else 
    for f in ./[a-zA-Z0-9_.]*; do
        if [[ "$f" == *"./*"* ]] || [[ -d "$f" ]]; then
            continue
        fi

        echo
        echo "<$f>"

        if [[ "$f" == *"stitch"* ]]; then
            lastTimeStamp=$[lastTimeStamp + 1]
            exifTime=$(exifDateFromTimestamp $lastTimeStamp)
            echo "Updating modified date to $lastTimeStamp ($(formattedDateFromTimestamp $lastTimeStamp)):"
            echo "-> Before: $(getExifDateTaken "$f") ($(formattedDateFromTimestamp $(getExifDateTaken "$f")))" 
            exiftool -overwrite_original -alldates="$exifTime" -filemodifydate="$exifTime" -filecreatedate="$exifTime" "$f" > /dev/null 2>&1
            echo "->  After: $(getExifDateTaken "$f") ($(formattedDateFromTimestamp $(getExifDateTaken "$f")))"  
            count=$[count + 1]
        else
            lastTimeStamp=$(getExifDateTaken "$f")
            echo "-> Found a valid timestamp: updating most recent timestamp to $lastTimeStamp ($(formattedDateFromTimestamp $lastTimeStamp))" 
        fi
    done

    echo
    echo "Finished: successfully restored dates for $count files"
fi 