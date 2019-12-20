check_commandline_arguments() {
  if [[ -z ${1} ]] ; then
    echo "cepheid extract and upload log archive from bosh to ELK"
    echo "cepheid.sh -p <path_to_archive> -h <es_host:port> -j <job_name>"
    return 1
  fi

  while [ "$1" != "" ]; do
    case $1 in
      -p ) archive_file="$2" ;;
      -j ) es_index_name="$2" ;;
    esac
    shift ; shift
  done
 }
