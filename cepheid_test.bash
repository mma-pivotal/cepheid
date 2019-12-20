T_always_passes() {
  echo "This is fine."
}

T_always_fails() {
  # shellcheck disable=SC2154
  $T_fail "This is terrible"
}
