#!/usr/bin/env bash

# Run data p8 with PICO-8 executable
# Pass any extra arguments to pico8
run_cmd="/Applications/PICO-8.app/Contents/MacOS/pico8 -run data.p8 -screenshot_scale 4 -gif_scale 4 $@"

echo "> $run_cmd"
bash -c "$run_cmd"
