#!/usr/bin/env coffee

debug = require('debug') 'gravatar'
express = require 'express'
config = require './config'
router = require('./index') config

for serverConfig in config.listenOn
  app = express()
  app.set 'x-powered-by', false
  app.set 'strict routing', true
  if serverConfig.headers?
    app.use (req, res, next) ->
      res.set serverConfig.headers
      next()
  app.use config.subpath, router

  module = require serverConfig.module

  if serverConfig.options?
    server = module.createServer serverConfig.options, app
  else
    server = module.createServer app

  port = process.env.PORT
  port ?= serverConfig.port

  server.listen port, serverConfig.hostname, () ->
    address = server.address().address
    port = server.address().port
    debug "Server listening on #{serverConfig.protocol}://#{address}:#{port}"
