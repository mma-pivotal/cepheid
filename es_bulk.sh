#! /bin/bash
es_host="10.193.26.207:9200"
mapping_name="log"
#hardcode es_host and mapping_name for now

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
#  gorouter)
#    job_file_name="access"
#    ;;
  *)
    echo "usage: es_bulk.sh <path_to_archive_file> <job_name>"
    echo "currently only support cloud_controller_ng logs"
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
  sub_path="$path_name/$deployment_name"
  mkdir $sub_path
  tar -xvzf $f -C $sub_path
  for sub_f in $sub_path/*
  do
    #second extration, extract job logs from instances
    instance_name=$(echo $sub_f | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
    instance_path="$sub_path/$instance_name"
    mkdir $instance_path
    tar -xvzf $sub_f -C $instance_path
    gunzip $instance_path/$job_name/$job_file_name.log*.gz
    rm -f $sub_f
    #remove archive file after it has been extracted

    for log_f in $instance_path/$job_name/$job_file_name.log*
    do
      echo "Processing $log_f"
      tempfile=$log_f.tmp
      outfile=$log_f.out
      echo "Output File: $outfile"

      sed -E 's|([0-9]{10})\.([0-9]{3})[0-9]+|\1\2|g' $log_f > $tempfile
      #change timestamp
      sed -E $'s/^/\{\"index\":\{\}\}\\\n/g' $tempfile > $outfile
      #add metadata

      nohup curl -s -H "Content-Type: application/x-ndjson" -XPOST  "$es_host/$job_name/$mapping_name/_bulk" --data-binary @$outfile  2>&1
      rm $tempfile $outfile
    done
    #parse and upload all job log files to remote es host
  done
  rm -f $path_name/*.tgz
#  rm -rf $path_name
  break
  #only extract once as each instance contains the logs for all instances, so no need to extract all instances
done

rm -rf $path_name
