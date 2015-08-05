fs = require 'fs'
path = require 'path'
request = require 'request'
lwip = require 'lwip'
cacheDir = path.resolve __dirname, 'cache'

module.exports = (req, res, next) ->
  size = req.query.s
  size ?= req.query.size
  size = parseInt(size, 10) || 80
  defaultUrl = req.query.d
  defaultUrl ?= req.query.default
  forceDefaultUrl = req.query.f
  forceDefaultUrl ?= req.query.force

  if defaultUrl in ['404', 'mm', 'identicon', 'monsterid', 'wavatar', 'retro', 'blank']
    defaultUrl = "//www.gravatar.com/avatar/00000000000000000000000000000000?d=#{defaultUrl}&f=y"

  if forceDefaultUrl is 'y'
    return res.redirect defaultUrl

  email = req.params.email
  [username, domain] = email.split '@'

  module.exports.maybeUseCache username, size, defaultUrl, res, (err) ->
    return next err  if err?

    onError = (err) ->
      if defaultUrl?
        res.redirect defaultUrl
      else
        next err

    onResponse = (response) ->
      file = fs.createWriteStream "#{cacheDir}/#{username}.jpg"
      response.pipe file
      module.exports.resizeCache username, size, (err) ->
        return next err  if err?
        if defaultUrl?
          res.redirect defaultUrl
        else
          res.status(404).send()

    request.get({url: "http://wwwin.cisco.com/dir/photo/zoom/#{username}.jpg"}) # CHANGEME
      .on('error', onError)
      .on('response', onResponse)

module.exports.maybeUseCache = (username, size, defaultUrl, res, next) ->
  if fs.exists "#{cacheDir}/#{username}.#{size}.jpg"
    res.sendFile "#{cacheDir}/#{username}.#{size}.jpg"
  else if fs.exists "#{cacheDir}/#{username}.jpg"
    resizeCache username, size, (err) ->
      return next err  if err?
      res.sendFile "#{cacheDir}/#{username}.#{size}.jpg"
  else
    res.redirect defaultUrl

module.exports.resizeCache = (username, size, next) ->
  lwip.open "#{cacheDir}/#{username}.jpg", (err, image) ->
    return next err  if err?

    width = image.width()
    height = image.height()
    refSize = Math.min width, height

    scaleRatio = 1
    if refSize > size
      scaleRatio = Math.round((size / refSize) * 100 * 100) / 100

    image.batch()
      .scale(scaleRatio)
      .crop(size, size)
      .writeFile "#{cacheDir}/#{username}.#{size}.jpg", next