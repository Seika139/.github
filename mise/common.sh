#!/bin/bash

get_python_version() {
  if [ -f .python-version ]; then
    cat .python-version | xargs
  else
    echo 'Error: .python-version not found'
    exit 1
  fi
}
