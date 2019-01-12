#! /bin/bash

function usage(){
    echo "cepheid extract and upload log archive from bosh to ELK"
    echo "cepheid.sh -p <path_to_archive> -h <es_host:port> -j <job_name>"
}

es_index_name="my_index"
es_mapping_name="_doc"
#default index and mapping name

while [ "$1" != "" ]; do
    case $1 in
        -p | --path )           shift
                                archive_file=$1
                                ;;
        -j | --job )            shift
                                job_name=$1
                                es_index_name=$1
                                ;;
        -h | --host )           shift       
                                es_host=$1
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

case "job_name" in
  cloud_controller_ng)
    job_file_name="cloud_controller_ng.log*"
    parser_name="json"
    ;;
  gorouter)
    parser_name="gorouter"
    job_file_name="access.log*"
    ;;
  diego_brain)   
    parser_name="json"
    job_file_name="auctioneer.stdout.log*"
    ;;
  *)
    echo "currently only support cloud_controller_ng diego_brain logs"
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

  if [[ $? -ne 0 ]]
  then
    echo "Failed to Extract $f"
    exit 1
  fi

  for sub_f in $sub_path/*
  do
    #second extration, extract job logs from instances
    instance_name=$(echo $sub_f | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev)
    instance_path="$sub_path/$instance_name"
    mkdir $instance_path
    tar -xvzf $sub_f -C $instance_path
    gunzip $instance_path/$job_name/$job_file_name
    rm -f $sub_f
    #remove archive file after it has been extracted

    for log_f in $instance_path/$job_name/$job_file_name
    do
      echo "Uploading $log_f"

      #cloud controller timestamp is not double-quoted while fluent-bit's json parser uses strptime to convert timestamp, adding double-quotation
      if [ $job_name eq "cloud_controller_ng" ]
      then
          sed -E -i .bak 's/([0-9]{10}\.[0-9]{7})/\"\1\"/' $log_f
          rm *.bak
      fi
      fluent-bit -R parsers.conf -i tail -p path=$log_f -p parser=$parser_name -p exit_on_eof='On' -o es://$es_host/$es_index_name/$es_mapping_name
    done
    #parse and upload all job log files to remote es host
  done
  rm -f $path_name/*.tgz
#  rm -rf $path_name
  break
  #only extract once as each instance contains the logs for all instances, so no need to extract all instances
done

rm -rf $path_name
