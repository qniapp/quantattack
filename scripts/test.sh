#!/bin/bash

# Configuration
game_src_path="$(dirname "$0")/../src"
picoboots_scripts_path="$(dirname "$0")/../pico-boots/scripts"

help() {
  echo "Test pico-boots modules with busted
This is essentially a proxy script for scripts/test_scripts.sh that avoids
passing src/engine/FOLDER every time we want to test a group of scripts.
Dependencies:
- busted (must be in PATH)
- luacov (must be in PATH)
"
usage
}

usage() {
  echo "Usage: test.sh
EXTRA PARAMETERS
  Any extra parameter is passed to scripts/test_scripts.sh (besides the ROOT arguments
    and --cov-config parameter).
  Enter 'scripts/test_scripts.sh --help' (from pico-boots root) for more information.
  -h, --help                Show this help message
"
}

# Read arguments
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
while [[ $# -gt 0 ]]; do
  case $1 in
    -h | --help )
      help
      exit 0
      ;;
    -* )    # we started adding options
            # since we don't support "--" for final positional arguments, just pass all the rest to test_scripts.sh
      break
      ;;
    * )
      shift # past argument
      ;;
  esac
done

"$picoboots_scripts_path/test_scripts.sh" test --lua-root "$game_src_path" $@
