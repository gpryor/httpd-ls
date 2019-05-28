#!/usr/bin/coffee
# -*- compile-command: "./test.sh"; -*-
http = require 'http'
fs = require 'fs'
assert = require 'assert'
url = require 'url'
mime = require 'mime'
async = require 'async'
fg = require 'fast-glob'
parseRangeHeader = require 'parse-http-range-header'
wcL = require 'unix-wc-l'
headTail = require 'unix-head-tail'
_500 = (res, msg) -> res.writeHead 500; res.end (msg or '')
_404 = (res, msg) -> res.writeHead 404; res.end (msg or '')
M = (s) -> console.log s; s


BASE_DIR=process.env.BASE_DIR or process.cwd()

sendFile = (res, path) ->
  fs.readFile path, (err, data) ->
    if err then return _404 res
    M "  << send #{path} (#{data.length} bytes)"
    res.setHeader 'Content-Type', mime.getType path
    res.writeHead 200
    res.end data

sendJson = (res, json) ->
  M "  << send JSON (#{json.length} bytes)"
  res.setHeader 'Content-Type', 'application/json'
  res.writeHead 200; res.end json

globToJson = (glob, cwd, cb) ->

  glob = glob.replace /\\/g, '/'
  cwdPat = new RegExp "^#{cwd}."

  entriesToJson = (entries) ->
    json = JSON.stringify entries.map (e) ->
      name: e.path.replace cwdPat, ''
      atime: e.atime
      mtime: e.mtime
      ctime: e.ctime
    cb false, json

  fg(glob, stats: true).then(entriesToJson) # .catch () -> cb true


rangeToUnits = (range) ->
  match = range.match /^[ ]*([^= ]+)[ ]*=/
  if match then match[1].toLowerCase()


sendFileLines = (res, path, ranges) ->

  sendRanges = (nlines) ->

    lineRangeToBuffer = (range, cb) ->
      [firstLineNo, lastLineNo] = range
      headTail path, firstLineNo, lastLineNo, (err, data) ->
        return cb err if err
        cb undefined, data

    async.map ranges, lineRangeToBuffer, (err, buffers) ->
      return _500 res if err
      payload = Buffer.concat buffers
      res.setHeader 'Content-Type', mime.getType path
      res.writeHead 200
      res.end payload

  wcL(path).then(sendRanges)



dirToGlob = (dir) ->
  if dir[dir.length - 1] isnt '/' then dir + '/*' else dir + '*'

server = http.createServer (req, res) ->
  return _404 res if req.method isnt 'GET'

  absPath = "#{BASE_DIR}#{(url.parse req.url).pathname.trim()}"
  range = if req.headers.range then parseRangeHeader req.headers.range

  fs.stat absPath, (err, stat) ->
    switch
      when not err and stat.isFile()
        if range
          return _404 res if range.unit isnt 'lines'
          sendFileLines res, absPath, range.ranges
        else
          sendFile res, absPath
      when not err and stat.isDirectory()
        globToJson (dirToGlob absPath), BASE_DIR, (err, json) ->
          return _404 res if err
          sendJson res, json
      else
        globToJson absPath, BASE_DIR, (err, json) ->
          return _404 res if err
          sendJson res, json

server.listen process.env.PORT or 8001, () -> M 'server started'
