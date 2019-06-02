#!/bin/bash
# -*- compile-command: "./test.sh"; -*-
set -ex
. $(dirname $(readlink -f $0))/util.sh

PORT=8001
TEST_DIR="$(dirname $(readlink -f $0))/test"
if [ "$(uname)" = "Linux" ] ; then
  export BASE_DIR=$TEST_DIR
fi
if [[ "$(uname)" =~ CYGWIN_.* ]] ; then
  export BASE_DIR=$(cygpath -wa $TEST_DIR)
fi


coffee index.coffee &   # BASE_DIR utilized here


COFFEE_PID=$!
function cleanup {
  kill_local_pid $COFFEE_PID
}
trap cleanup SIGINT SIGTERM EXIT

wait_for_server 8001


# retrieves full file
cmp <(curl -s http://localhost:8001/log/0_clone.0001) $TEST_DIR/log/0_clone.0001

# retrieves glob
curl -s http://localhost:$PORT/log/0_*01 | grep -o '0_clone.0001' > /dev/null

# retrieves directory
[ $(curl -s http://localhost:$PORT/log/* | grep -o '0_clone' | wc -l) = "3" ]

# retrieves part of file
cmp <(curl -H "range: lines=3-7" -s http://localhost:8001/log/0_clone.0001) \
    <(head -n 7 $TEST_DIR/log/0_clone.0001 | tail -n +3)

# retrieves end of file
cmp <(curl -H "range: lines=-2" -s http://localhost:8001/log/0_clone.0001) \
    <(head -n 6 $TEST_DIR/log/0_clone.0001 | tail -n +5)

# retrieves starting at line
cmp <(curl -H "range: lines=3-" -s http://localhost:8001/log/0_clone.0001) \
    <(tail -n +3 $TEST_DIR/log/0_clone.0001)
