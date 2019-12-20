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
  local archive_file
  if ! check_commandline_arguments -p "test_value" > /dev/null ; then
    $T_fail "Expected check_commandline_arguments to assgin value to archive_file when flag -p is set"
  fi

  if [[ -z $archive_file ]]; then
    $T_fail "Expected archive_file to have a value"
  fi

  if [[ $archive_file != "test_value" ]] ; then
    $T_fail "Expected archive_file to be \'test_value\', but instead its \'$archive_file\'"
  fi
}

T_when_the_flag_is_j_check_commandline_arguments_should_assign_a_value_to_es_index_name() {
  local es_index_name
  if ! check_commandline_arguments -j "test_value" > /dev/null ; then
    $T_fail "Expected check_commandline_arguments to assgin value to es_index_name when flag -j is set"
  fi

  if [[ $es_index_name != "test_value" ]] ; then
    $T_fail "Expected es_index_name to be \'test_value\', but instead its \'$es_index_name\'"
  fi
}

T_when_two_flags_are_passed_both_values_should_be_set() {
  local archive_file es_index_name

  if ! check_commandline_arguments -p "archive_value" -j "test_value" > /dev/null ; then
    $T_fail "Expected check_commandline_arguments to assgin values when flags are set"
  fi

  if [[ $archive_file != "archive_value" ]] ; then
    $T_fail "Expected archive_file to be \'archive_value\', but instead its \'$archive_file\'"
  fi

  if [[ $es_index_name != "test_value" ]] ; then
    $T_fail "Expected es_index_name to be \'test_value\', but instead its \'$es_index_name\'"
  fi
}
