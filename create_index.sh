#! /bin/bash

function usage(){
    echo "This script create new index in elasticsearch"
    echo "create_index.sh -h <es_host:port> -i <es_index_name/job_name>"
}

index_name="my_index"
mapping_name="_doc"
#default index and mapping name

while [ "$1" != "" ]; do
    case $1 in
        -i | --index )          shift
                                es_index_name=$1
                                ;;
        -h | --host )           shift       
                                es_host=$1
                                ;;
        * )                     usage
                                exit 1
                                ;;
    esac
    shift
done

if [ -z "$es_host" ]
then
    usage  
    exit 1
fi

case "$es_index_name" in
  cloud_controller_ng)
    job_file_name="cloud_controller_ng.log*"
    object='{"mappings":{"_doc":{"properties":{}}}}'
    ;;
  gorouter)
    job_file_name="access.log*"
    object='{"mappings":{"_doc":{"properties":{"response_time":{"type":"double"}}}}}'
    ;;
  diego_brain)
    job_file_name="auctioneer.stdout.log*"
    object='{"mappings":{"_doc":{"properties":{"timestamp":{"type":"date","format":"epoch_millis"}}}}}'
    ;;
  *)
    echo "currently only support cloud_controller_ng diego_brain logs"
    exit 1
    ;;
esac

echo "creating new index"
nohup curl -H "Content-Type: application/json"  -XPUT  "$es_host/$es_index_name" -d $object  2>&1