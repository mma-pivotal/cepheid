. cepheid_lib.bash

T_check_commandline_arguments_errors_with_no_argument() {
  if check_commandline_arguments ; then
    # shellcheck disable=SC2154
    $T_fail "Expected check_commandline_arguments to fail with no arguments, but it did not"
  fi
}

T_check_commandline_arguments_returns_usage_with_no_argument() {
  local output
  output=$(check_commandline_arguments)
  # shellcheck disable=SC2076
  if ! [[ $output =~ "cepheid extract and upload log archive from bosh to ELK"  &&
          $output =~ "cepheid.sh -p <path_to_archive> -h <es_host:port> -j <job_name>" ]]  ; then
      # shellcheck disable=SC2154
      $T_fail "Expected check_commandline_arguments to output usage when no arguments is passed"
  fi
}

T_when_the_flag_is_p_check_commandline_arguments_should_assign_a_value_to_archive_file() {
  #local archive_file
  if ! check_commandline_arguments -p "test_value" > /dev/null ; then
    $T_fail "Expected check_commandline_arguments to assgin value to archive_file when flag -p is set"
  fi
}
