#!/bin/bash

T_RED='\033[0;31m'
T_GREEN='\033[0;32m'
T_YELLOW='\033[0;33m'
T_BLUE='\033[0;34m'
T_MAGENTA='\033[0;35m'
T_CYAN='\033[0;36m'
T_WHITE='\033[0;37m'
T_RESET='\033[0m'

# 共通の内部処理関数
log_internal() {
  local color="${1:-}"
  shift
  local nl="\n"
  if [[ "${1:-}" == "-n" ]]; then
    nl=""
    shift
  fi
  printf "%b%s%b$nl" "$color" "$*" "$T_RESET"
}

log_red() { log_internal "$T_RED" "$@"; }
log_green() { log_internal "$T_GREEN" "$@"; }
log_yellow() { log_internal "$T_YELLOW" "$@"; }
log_blue() { log_internal "$T_BLUE" "$@"; }
log_magenta() { log_internal "$T_MAGENTA" "$@"; }
log_cyan() { log_internal "$T_CYAN" "$@"; }
log_white() { log_internal "$T_WHITE" "$@"; }

get_python_version() {
  if [ -s .python-version ]; then
    xargs <.python-version
  else
    echo 'Error: .python-version not found or is empty' >&2
    exit 1
  fi
}
