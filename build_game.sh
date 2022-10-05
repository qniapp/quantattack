#!/usr/bin/env bash

./scripts/build_cartridge.sh src main.lua src -o build/game --data data.p8 -s assert,log,visual_logger,tuner,profiler,mouse
