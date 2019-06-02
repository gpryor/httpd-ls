#!/bin/bash
# -*- compile-command: "./util.sh"; -*-

function wait_for_server() {
  COUNT=0
  if [ -z "$TIMEOUT" ] ; then TIMEOUT=5 ; fi
  while ! nc -z 127.0.0.1 $1 > /dev/null ; do
    sleep 1s
    COUNT=$((COUNT + 1))

    if [ $COUNT == $TIMEOUT ] ; then
      echo [FAIL] server at $1 not responding after $TIMEOUT seconds
      exit 1
    fi
  done
}

function kill_local_pid() {
  while kill -0 $1 2>/dev/null ; do
    kill $1
    sleep 1s
  done
}
