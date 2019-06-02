# httpd-ls

[![Build Status](https://travis-ci.org/gpryor/httpd-ls.svg?branch=master)](https://travis-ci.org/gpryor/httpd-ls)

Utilize filesystem as rustic database through REST requests to an
ultra-minimalist httpd. Performs `ls <glob>` and static `GET` supporting
`range` headers to wrangle large filesystem operations.

Cross-platform: windows, cygwin, and linux. CI tests latter.

```
// serve
PORT=8001 BASE_DIR="$(pwd)/test" coffee index.coffee &

// directory listing `ls -R` as json
curl localhost:8001/**
// -> [ { name: "test/config.json", atime: "", mtime:"", ctime:"" }
//       ... ]

curl localhost:8001/test/*.json
// -> [ { name: "test/log/0_clone.0000", atime: "", mtime:"", ctime:"" }
//       ... ]

// tail -n 1 <filename>
curl -H "range: lines=-1" localhost:8001/test/log/0_clone.0000
// -> 010

// retrieve middle of file
curl -H "range: lines=3-5" <host>/<filename>
// ->
//  "0_clone":                ["chk.sh 0_clone"                , "1_build"],
//  "1_build":                ["chk.sh 1_build"                , "2_exec"],
//  "2_exec":                 ["chk.sh 2_exec"                 , "4_clone_mona"],
```
