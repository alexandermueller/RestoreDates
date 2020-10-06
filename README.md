# RestoreDates
Restore timestamp data to any image file with a partial or full timestamp in its name (using said timestamp.)

This is very useful when stitching images together at a later date than when the images were taken, which would (usually) create
an image file with one of the original timestamps in the name (like Microsoft ICE does by default), but assigned the creation date
to the current date.

Works with any timestamped file that contains YYYYmmdd_HHMMSS inside the filename (essentially 14 digits long.)

eg: PXL_20201005_180522322_stitch.png -> "20201005_180522"

If the timestamp contains more than 14 digits, it will truncate down to 14 digits.

If the timestamp contains more than 1 but less than 14 digits, it will concatenate 0s to the timestamp until there are 14 digits.
This can lead to some dates that don't make sense, so year/month/date default to 1991/01/01 if year/month/date falls below those values.

A timestamp may also be separated by more than 1 underscore as well, ie, 2020_01_01_16_50_02 -> 20200101165002
