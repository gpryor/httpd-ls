#!/usr/bin/coffee
# -*- compile-command: "./test.sh"; -*-
http = require 'http'
fs = require 'fs'
assert = require 'assert'
url = require 'url'
path = require 'path'
mime = require 'mime'
async = require 'async'
fg = require 'fast-glob'
parseRange = require 'range-parser'
_500 = (res, msg) -> res.writeHead 500; res.end (msg or '')
_404 = (res, msg) -> res.writeHead 404; res.end (msg or '')
M = (s) -> console.log s; s


BASE_DIR=process.env.BASE_DIR or process.cwd()

sendFile = (res, path) ->
  fs.readFile path, (err, data) ->
    if err then return _404 res
    M "  << send #{path} (#{data.length} bytes)"
    res.setHeader 'Content-Type', mime.getType path
    res.writeHead 200; res.end data

sendJson = (res, json) ->
  M "  << send JSON (#{json.length} bytes)"
  res.setHeader 'Content-Type', 'application/json'
  res.writeHead 200; res.end json

globToJson = (glob, cwd, cb) ->

  glob = glob.replace '\\', '\\\\'
  cwdPat = new RegExp "^#{cwd}."

  entriesToJson = (entries) ->
    json = JSON.stringify entries.map (e) ->
      name: e.path.replace cwdPat, ''
      atime: e.atime
      mtime: e.mtime
      ctime: e.ctime
    cb false, json

  fg(glob, stats: true).then(entriesToJson).catch () -> cb true

server = http.createServer (req, res) ->
  _404 res if req.method isnt 'GET'

  # if req.headers.range
  #   M parseRange req.headers.range,

  absPath = "#{BASE_DIR}#{(url.parse req.url).pathname.trim()}"
  fs.stat absPath, (err, stat) ->
    return _404 res if err
    return sendFile res, absPath if stat.isFile()
    if stat.isDirectory()
      absPath += '/' if absPath[absPath.length - 1] isnt '/'
      absPath += '*'
    globToJson absPath, BASE_DIR, (err, json) ->
      _404 res if err
      sendJson res, json



  # notdir = (s) -> s.match(/\/([^\/]*)$/)[1]
  # filename = notdir (url.parse req.url).pathname
  # M "req #{filename}"
  # switch filename
  #   when '' then send res, "#{__dirname}/index.html"
  #   when 'socket.io.js' then send res, socketioPath
  #   when 'favicon.ico' then res.writeHead 404; res.end()
  #   when 'index.css'
  #     send res, (css or "#{__dirname}/index.css")
  #   else
  #     fullPath = "#{__dirname}/#{filename}"
  #     if fs.statSync fullPath
  #       send res, fullPath
  #     else
  #       res.writeHead 302, {Location: "index.html"}
  #       res.end()

server.listen process.env.PORT or 8001, () -> M 'server started'
