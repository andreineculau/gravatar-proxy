fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
debug = require('debug') 'gravatar'

express = require 'express'
morgan = require 'morgan'

module.exports = exports = (config = {}) ->
  if config.knownHashesFilename?
    config.knownHashesFilename = path.resolve __dirname, config.knownHashesFilename
    unless fs.existsSync config.knownHashesFilename
      fs.writeFileSync config.knownHashesFilename, '{}'
    knownHashes = require config.knownHashesFilename

  app = express.Router {strict: true}

  app.use morgan config.morgan.format

  app.get '/:hash', (req, res, next) ->
    [req.params.hash, req.params.format] = req.params.hash.split '.'
    req.params.email = knownHashes[req.params.hash]
    unless req.params.email? or config.allowUnknownHashes
      res.status(404).send()
    unless config.getAvatarFun?
      res.status(404).send()
    config.getAvatarFun req, res, next

  app.put '/:hash', (req, res, next) ->
    {hash} = req.params
    return res.status(400).send()  unless hash?
    {email} = req.query
    email = email?.toLowerCase().trim()
    knownHashes = require config.knownHashesFilename
    knownHashes[hash] = email
    fs.writeFile config.knownHashesFilename, JSON.stringify(knownHashes, null, 2), (err) ->
      return next err  if err?
      res.status(204).send()

  app.post '/', (req, res, next) ->
    {email} = req.query
    return res.status(400).send()  unless email?
    email = email.toLowerCase().trim()
    hash = crypto.createHash('md5').update(email).digest('hex')
    knownHashes = require config.knownHashesFilename
    knownHashes[hash] = email
    fs.writeFile config.knownHashesFilename, JSON.stringify(knownHashes, null, 2), (err) ->
      return next err  if err?
      res.status(204).send()

  app
