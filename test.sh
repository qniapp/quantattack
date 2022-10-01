#!/bin/bash

# Configuration
game_src_path="$(dirname "$0")/src"
game_config_path="$(dirname "$0")/config"
picoboots_scripts_path="$(dirname "$0")/pico-boots/scripts"

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
  echo "Usage: test.sh [FOLDER-1 [FOLDER-2 [...]]]
ARGUMENTS
  FOLDER                    Path to engine folder to test.
                            Path is relative to src/engine. Sub-folders are supported.
                            (optional)
EXTRA PARAMETERS
  Any extra parameter is passed to scripts/test_scripts.sh (besides the ROOT arguments
    and --cov-config parameter).
  Enter 'scripts/test_scripts.sh --help' (from pico-boots root) for more information.
  -h, --help                Show this help message
"
}

# Default parameters
folders=()
other_options=()

# Read arguments
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
roots=()
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
    * )     # positional argument: folder
      folders+=("$1")
      shift # past argument
      ;;
  esac
done

if [[ ${#folders[@]} -ne 0 ]]; then
  # Paths are relative to src/engine, so prepend it before passing to actual test script
  for folder in "${folders[@]}"; do
    roots+=("\"$game_src_path/$folder\"")
  done
else
  # No folder passed, test the whole engine folder
  roots=("\"$game_src_path\"")
fi

"$picoboots_scripts_path/test_scripts.sh" ${roots[@]} --lua-root src -c "$game_config_path/.luacov_game" $@
