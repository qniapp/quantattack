#!/bin/bash

# Configuration
picoboots_src_path="$(dirname "$0")/pico-boots/src"
picoboots_scripts_path="$(dirname "$0")/pico-boots/scripts"

help() {
  echo "Build .p8 file from a main source file with picotool.

It may be used to build an actual game or an integration test runner.

The game file may require any scripts by its relative path from the game source root directory,
and any engine scripts by its relative path from pico-boots source directory.

If --minify-level MINIFY_LEVEL is passed with MINIFY_LEVEL >= 1,
the lua code of the output cartridge is minified using the local luamin installed via npm.

System dependencies:
- picotool (p8tool must be in PATH)

Local dependencies:
- luamin#feature/newline-separator (installed via npm install/update inside npm folder)
"
usage
}

usage() {
  echo "Usage: build_game.sh GAME_SRC_PATH RELATIVE_MAIN_FILEPATH [REQUIRED_RELATIVE_DIRPATH]

ARGUMENTS
  GAME_SRC_PATH                 Path to the game source root.
                                Path is relative to the current working directory.
                                All 'require's should be relative to that directory.
                                Ex: 'src'

  RELATIVE_MAIN_FILEPATH        Path to main lua file.
                                Path is relative to GAME_SRC_PATH,
                                and contains the extension '.lua'.
                                Ex: 'main.lua'

  REQUIRED_RELATIVE_DIRPATH     Optional path to directory containing files to require.
                                Path is relative to the game source directory.
                                If it is set, pre-build will add require statements for any module
                                found recursively under this directory, in the main source file.
                                This is used with itest_main.lua to inject itests via auto-registration
                                on require.
                                Do not put files containing non-PICO-8 compatible code in this folder!
                                (in particular advanced Lua and busted-specific functions meant for
                                headless unit tests)
                                Ex: 'itests'

OPTIONS
  -p, --output-path OUTPUT_PATH Path to build output directory.
                                Path is relative to the current working directory.
                                (default: '.')

  -o, --output-basename OUTPUT_BASENAME
                                Basename of the p8 file to build.
                                If CONFIG is set, '_{CONFIG}' is appended.
                                Finally, '.p8' is appended.
                                (default: 'game')

  -c, --config CONFIG           Build config. Since preprocessor symbols are passed separately,
                                this is only used to determine the intermediate and output paths.
                                If no config is passed, we assume the project has a single config
                                and we don't use intermediate sub-folder not output file suffix.
                                (default: '')

  -s, --symbols SYMBOLS_STRING  String containing symbols to define for the preprocess step
                                (parsing #if [symbol]), separated by ','.
                                Ex: -s symbol1,symbol2 ...
                                (default: no symbols defined)

  -d, --data DATA_FILEPATH      Path to data p8 file containing gfx, gff, map, sfx and music sections.
                                Path is relative to the current working directory,
                                and contains the extension '.p8'.
                                (default: '')

  -M, --metadata METADATA_FILEPATH
                                Path the file containing cartridge metadata. Title and author are added
                                manually with the options below, so in practice, it should only contain
                                the label picture for export.
                                Path is relative to the current working directory,
                                and contains the extension '.p8'.
                                (default: '')

  -t, --title TITLE             Game title to insert in the cartridge metadata header
                                (default: '')

  -a, --author AUTHOR           Author name to insert in the cartridge metadata header
                                (default: '')

  -m, --minify-level MINIFY_LEVEL
                                Minify the output cartridge __lua__ section, using newlines as separator
                                for minimum readability.
                                MINIFY_LEVEL values:
                                  0: no minification
                                  1: basic minification
                                  2: aggressive minification (minify member names and table key strings)
                                  CAUTION: when using level 2, make sure to use the [\"key\"] syntax
                                           for any key you need to preserve during minification (see README.md)
                                (default: 0)

  -h, --help                    Show this help message
"
}

# Default parameters
output_path='.'
output_basename='game'
config=''
symbols_string=''
data_filepath=''
metadata_filepath=''
title=''
author=''
minify_level=0

# Read arguments
positional_args=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -p | --output-path )
      if [[ $# -lt 2 ]] ; then
        echo "Missing argument for $1"
        usage
        exit 1
      fi
      output_path="$2"
      shift # past argument
      shift # past value
      ;;
    -o | --output-basename )
      if [[ $# -lt 2 ]] ; then
        echo "Missing argument for $1"
        usage
        exit 1
      fi
      output_basename="$2"
      shift # past argument
      shift # past value
      ;;
    -c | --config )
      if [[ $# -lt 2 ]] ; then
        echo "Missing argument for $1"
        usage
        exit 1
      fi
      config="$2"
      shift # past argument
      shift # past value
      ;;
    -s | --symbols )
      if [[ $# -lt 2 ]] ; then
        echo "Missing argument for $1"
        usage
        exit 1
      fi
      symbols_string="$2"
      shift # past argument
      shift # past value
      ;;
    -d | --data )
      if [[ $# -lt 2 ]] ; then
        echo "Missing argument for $1"
        usage
        exit 1
      fi
      data_filepath="$2"
      shift # past argument
      shift # past value
      ;;
    -M | --metadata )
      if [[ $# -lt 2 ]] ; then
        echo "Missing argument for $1"
        usage
        exit 1
      fi
      metadata_filepath="$2"
      shift # past argument
      shift # past value
      ;;
    -t | --title )
      if [[ $# -lt 2 ]] ; then
        echo "Missing argument for $1"
        usage
        exit 1
      fi
      title="$2"
      shift # past argument
      shift # past value
      ;;
    -a | --author )
      if [[ $# -lt 2 ]] ; then
        echo "Missing argument for $1"
        usage
        exit 1
      fi
      author="$2"
      shift # past argument
      shift # past value
      ;;
    -m | --minify-level )
      if [[ $# -lt 2 ]] ; then
        echo "Missing argument for $1"
        usage
        exit 1
      fi
      minify_level="$2"
      shift # past argument
      shift # past value
      ;;
    -h | --help )
      help
      exit 0
      ;;
    -* )    # unknown option
      echo "Unknown option: '$1'"
      usage
      exit 1
      ;;
    * )     # store positional argument for later
      positional_args+=("$1")
      shift # past argument
      ;;
  esac
done

if ! [[ ${#positional_args[@]} -ge 2 && ${#positional_args[@]} -le 3 ]]; then
  echo "Wrong number of positional arguments: found ${#positional_args[@]}, expected 2 or 3."
  echo "Passed positional arguments: ${positional_args[@]}"
  usage
  exit 1
fi

game_src_path="${positional_args[0]}"
relative_main_filepath="${positional_args[1]}"
required_relative_dirpath="${positional_args[2]}"  # optional

output_filename="$output_basename"

# if config is passed, append to output basename
if [[ -n "$config" ]] ; then
  output_filename+="_$config"
fi
output_filename+=".p8"

output_filepath="$output_path/$output_filename"

# Split symbols string into a array by splitting on ','
# https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash
IFS=',' read -ra symbols <<< "$symbols_string"

echo "Building '$game_src_path/$relative_main_filepath' -> '$output_filepath'"

# clean up any existing output file
rm -f "$output_filepath"

echo ""
echo "Pre-build..."

# Copy metadata.p8 to future output file path. When generating the .p8, p8tool will preserve the __label__ present
# at the output file path, so this is effectively a way to setup the label.
# However, title and author are lost during the process and must be manually added to the header with add_metadata.py

# Create directory for output file if it doesn't exist yet
mkdir -p $(dirname "$output_filepath")

if [[ -n "$data_filepath" ]] ; then
  if [[ -f "$metadata_filepath" ]]; then
  	cp_label_cmd="cp \"$metadata_filepath\" \"$output_filepath\""
  	echo "> $cp_label_cmd"
  	bash -c "$cp_label_cmd"

    if [[ $? -ne 0 ]]; then
      echo ""
      echo "Copy label step failed, STOP."
      exit 1
    fi
  fi
fi

# if config is passed, use intermediate sub-folder
intermediate_path='intermediate'
if [[ -n "$config" ]] ; then
  intermediate_path+="/$config"
fi

# create intermediate directory to prepare source copy
# (rsync can create the 'pico-boots' and 'src' sub-folders itself)
mkdir -p "$intermediate_path"

# Copy framework and game source to intermediate directory
# to apply pre-build steps without modifying the original files
rsync -rl --del "$picoboots_src_path/" "$intermediate_path/pico-boots"
rsync -rl --del "$game_src_path/" "$intermediate_path/src"
if [[ $? -ne 0 ]]; then
  echo ""
  echo "Copy source to intermediate step failed, STOP."
  exit 1
fi

# Apply preprocessing directives for given symbols (separated by space, so don't surround array var with quotes)
preprocess_itest_cmd="\"$picoboots_scripts_path/preprocess.py\" \"$intermediate_path\" --symbols ${symbols[@]}"
echo "> $preprocess_itest_cmd"
bash -c "$preprocess_itest_cmd"

if [[ $? -ne 0 ]]; then
  echo ""
  echo "Preprocess step failed, STOP."
  exit 1
fi

# If building an itest main, add itest require statements
if [[ -n "$required_relative_dirpath" ]] ; then
  add_require_itest_cmd="\"$picoboots_scripts_path/add_require.py\" \"$intermediate_path/src/$relative_main_filepath\" "$intermediate_path/src" \"$required_relative_dirpath\""
  echo "> $add_require_itest_cmd"
  bash -c "$add_require_itest_cmd"

  if [[ $? -ne 0 ]]; then
    echo ""
    echo "Add require step failed, STOP."
    exit 1
  fi
fi

echo ""
echo "Build..."

# picotool uses require paths relative to the requiring scripts, so for project source we need to indicate the full path
# support both requiring game modules and pico-boots modules
lua_path="$(pwd)/$intermediate_path/src/?.lua;$(pwd)/$intermediate_path/pico-boots/?.lua"

# if passing data, add each data section to the cartridge
if [[ -n "$data_filepath" ]] ; then
  data_options="--gfx \"$data_filepath\" --gff \"$data_filepath\" --map \"$data_filepath\" --sfx \"$data_filepath\" --music \"$data_filepath\""
fi

# Build the game from the main script
build_cmd="p8tool build --lua \"$intermediate_path/src/$relative_main_filepath\" --lua-path=\"$lua_path\" $data_options \"$output_filepath\""
echo "> $build_cmd"

if [[ "$config" == "release" ]]; then
  # We are building for release, so capture warnings mentioning
  # token count over limit.
  # (faster than running `p8tool stats` on the output file later)
  # Indeed, users should be able to play our cartridge with vanilla PICO-8.
  error=$(bash -c "$build_cmd 2>&1")
  # Store exit code for fail check later
  build_exit_code="$?"
  # Now still print the error for user, this includes real errors that will fail and exit below
  # and warnings on token/character count
  >&2 echo "$error"

  # Emphasize error on token count now, with extra comments
  # regex must be stored in string, then expanded
  # it doesn't support \d
  token_regex="token count ([0-9]+)"
  if [[ "$error" =~ $token_regex ]]; then
    # Token count above 8192 was detected by p8tool
    # However, p8tool count is wrong as it ignores the latest counting rules
    # which are more flexible. So just in case, we still not fail the build and
    # only print a warning.
    token_count=${BASH_REMATCH[1]}
    echo "token count of $token_count detected, but p8tool counts more tokens than PICO-8, so this is only an issue beyond ~8700 tokens."
  fi
else
  # Debug build is often over limit anyway, so don't check warnings
  # (they will still be output normally)
  bash -c "$build_cmd"
  # Store exit code for fail check below (just to be uniform with 'release' case)
  build_exit_code="$?"
fi

if [[ "$build_exit_code" -ne 0 ]]; then
  echo ""
  echo "Build step failed, STOP."
  exit 1
fi

echo ""
echo "Post-build..."

if [[ "$minify_level" -gt 0  ]]; then
  minify_cmd="$picoboots_scripts_path/minify.py \"$output_filepath\""
  if [[ "$minify_level" -ge 2  ]]; then
    minify_cmd+=" --aggressive-minify"
  fi
  echo "> $minify_cmd"
  bash -c "$minify_cmd"

  if [[ $? -ne 0 ]]; then
    echo "Minification failed, STOP."
    exit 1
  fi
fi

if [[ -n "$title" || -n "$author" ]] ; then
  # Add metadata to cartridge
  # Since label has been setup during Prebuild, we don't need to add it with add_metadata.py anymore
  # Thefore, for the `label_filepath` argument just pass the none value "-"
  add_header_cmd="$picoboots_scripts_path/add_metadata.py \"$output_filepath\" \"-\" \"$title\" \"$author\""
  echo "> $add_header_cmd"
  bash -c "$add_header_cmd"

  if [[ $? -ne 0 ]]; then
    echo ""
    echo "Add metadata failed, STOP."
    exit 1
  fi
fi

echo ""
echo "Build succeeded: '$output_filepath'"
