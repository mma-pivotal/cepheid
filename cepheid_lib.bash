check_commandline_arguments() {
  echo "cepheid extract and upload log archive from bosh to ELK"
  echo "cepheid.sh -p <path_to_archive> -h <es_host:port> -j <job_name>"
  return 1
}
