#!/bin/bash

get_python_version() {
  if [ -s .python-version ]; then
    xargs <.python-version
  else
    echo 'Error: .python-version not found or is empty' >&2
    exit 1
  fi
}
