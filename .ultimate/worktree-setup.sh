#!/bin/sh
# Runs in each new worktree (coordinators, workers, lander). Safe to repeat.
# pico-boots (build + test scripts) is a git submodule; reuse the source checkout's objects.
git submodule update --init --reference "$ULTIMATE_SOURCE/pico-boots"
