#!/bin/bash

#make a new temp folder and copy all cloud_controller_ng log file into this new temp folder, then unzip.

mkdir tmp
cp -f cloud_controller_ng.log* tmp
gunzip tmp/cloud_controller_ng*
es_host="10.193.26.207:9200"

FILES="$PWD/tmp/*"

for f in $FILES
do
  echo "Processing $f"
  outfile="$f.out"
  echo "Outfile: $outfile"
  echo "Start Time: $SECONDS"
  while read -r p; do
    echo "{\"index\":{}}" >> $outfile
    echo "$p" | sed -E 's|([0-9]{10})\.([0-9]{3})[0-9]+|\1\2|g' >> $outfile
#    sed is very slow, takes more than 1 hour to finish 5 cc log file parsing.

#    text=$(echo $p | cut -f 2- -d ",")
#    echo "${p:0:23}${p:24:3},$text" >> $outfile
#    substring is even worse

#    re="([0-9]{10})\.([0-9]{3})[0-9]+"
#
#    [[ $p =~ $re ]]
#    line=$()
#    hello="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
#
#    echo "" >> $outfile
#    bash native regex is also slow
  done < $f
  echo "End Time: $SECONDS"
  nohup curl -s -H "Content-Type: application/x-ndjson" -XPOST  "$es_host/myindex/_doc/_bulk" --data-binary @$outfile > /dev/null 2>&1
done

#https://stackoverflow.com/questions/5624969/how-to-reference-captures-in-bash-regex-replacement
