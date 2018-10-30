#! /bin/bash
#replace epoch timestamp with human readable timestamp in cloud_controller log

file_name=$1
outfile_name="$file_name.out"

while read -r p; do
	time=$(echo $p | grep -Eow '\d{10}' | xargs date -u -r)
	#currently only works in MacOS, for ubuntu the command should be date -d @timestamp, also it's better to add support for milliseconds as well
	time="\"$time\""
	echo $p | sed -E 's|([0-9]{10})\.[0-9]+|'"$time"'|g' >> $outfile_name
done < $file_name
