#! /bin/bash

bulk_upload() {
  FILES="$1/*"

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
    nohup url -s -H "Content-Type: application/x-ndjson" -XPOST  "$es_host/$job_name/cloud_controller/_bulk" --data-binary @$outfile > /dev/null 2>&1
  done
  return 0
}

if [[ ! -z "$1" ]]
then
  archive_file=$1
else
  echo "Archive File Not Found"
  exit 1
fi

if [[ ! -z "$2" ]]
then
  job_name=$2
else
  echo "No Job Name Specified"
  exit 1
fi

case "$job_name" in
  cloud_controller_ng)
    job_file_name="cloud_controller_ng"
    ;;
  gorouter)
    job_file_name="access"
    ;;
  *)
    echo "currently only support cloud_controller_ng|gorouter logs"
    exit 1
    ;;
esac

file_name=$(echo $archive_file | rev | cut -f 2 -d "." | cut -f 1 -d "/" | rev)
path_name="/tmp/$file_name"
mkdir $path_name
unzip $archive_file -d $path_name

if [[ $? -ne 0 ]]
then
  echo "Failed to Extract $archive_file"
  exit 1
fi

for f in $path_name/*
do
  #first extrcation, extract instance logs from deployment
  deployment_name=$(echo $f | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
  sub_path="$deployment_name/$file_name"
  mkdir $sub_path
  tar -xvzf $f -C $sub_path
  for sub_f in $sub_path/*
  do
    #second extration, extract job logs from instances
    instance_name=$(echo $sub_f | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
    instance_path="$sub_path/$instance_name"
    mkdir $instance_path
    tar -xvzf $sub_f -C $instance_path
    rm -f $sub_f
    #remove archive file after it has been extracted

  done
  rm -f $path_name/*.tgz
#  rm -rf $path_name
  exit 0
  #only extract once as each instance contains the logs for all instances, so no need to extract all instances
done
