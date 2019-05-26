#!/bin/bash
# -*- compile-command: "./test.sh"; -*-
set -e

PORT=8001
export BASE_DIR="C:/cygwin64/home/gpryor/wm.devops/out/exec"

coffee index.coffee &
sleep 1s

# cmp <(curl -s http://localhost:$PORT/jobs) $CONFIG_JSON
# [ $(curl -sIw '%{http_code}' http://localhost:$PORT/log/* | tail -n 1) = "200" ]

curl -H "Range: line=-1" -s http://localhost:8001/log/0_clone.0004 > /dev/null
