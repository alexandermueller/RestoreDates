# RestoreDates
Restore timestamp data to any image file with a partial or full timestamp in its name (using said timestamp.)

This is very useful when stitching images together at a later date than when the images were taken, which would (usually) create
an image file with one of the original timestamps in the name (like Microsoft ICE does by default), but assigns the creation date
to the current date.

Works with any timestamped file that contains YYYYmmdd_HHMMSS inside the filename (essentially 14 digits long), ie:
```
PXL_20201005_180522322_stitch.png -> 2020-10-05 18:05:22
```

If the timestamp contains more than 14 digits, it will truncate down to 14 digits.

If the timestamp contains more than 1 but less than 14 digits, it will concatenate 0s to the timestamp until there are 14 digits.
This can lead to some dates that don't make sense, so year/month/date default to 1991/01/01 if year/month/date falls below those values.

A timestamp may also be separated by 0 or more underscores: 
```
2020_01_01_16_50_02 -> 2020-01-01 16:50:02
20200101165002      -> 2020-01-01 16:50:02
2                   -> 2000-01-01 00:00:00
0                   -> 1991-01-01 00:00:00
```

# RestoreDatesSansTimestamp
Restore timestamp data to any stitched file in a directory without a timestamp in its name.

Searches the current dir for image files that haven't been stitched yet, using the first one it sees to initialize a rolling unix
timestamp counter to the closest midnight from before that timestamp. ie:
```
1577915402 (2020-01-01 16:50:02 EST) -> 1577854800 (2020-01-01 00:00:00 EST)
```
It searches for non-stitched images first because the stitched images will have creation dates that don't match the files that went 
into creating them. 

Next it iterates through all the image files in the current dir, updating the rolling timestamp to the current file's taken date if
the file is a regular image file, otherwise setting the current (stitched) image file's taken date (and all other timestamps if
possible) to the rolling timestamp's date (+1 second.) The exact timestamp is not really necessary here for me, I just wanted to 
keep the correct ordering when exporting them into Google Photos.
