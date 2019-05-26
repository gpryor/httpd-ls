#!/bin/bash
# -*- compile-command: "./test.sh"; -*-
set -e

PORT=8001
BASE_DIR="$(dirname $(readlink -f $0))/test"

BASE_DIR=$(cygpath -wa $BASE_DIR) coffee index.coffee &
sleep 1s

# retrieves full file
cmp <(curl -s http://localhost:8001/log/0_clone.0001) $BASE_DIR/log/0_clone.0001

# retrieves glob
curl -s http://localhost:$PORT/log/0_*01 | grep -o '0_clone.0001' > /dev/null

# retrieves directory
[ $(curl -s http://localhost:$PORT/log/* | grep -o '0_clone' | wc -l) = "3" ]
