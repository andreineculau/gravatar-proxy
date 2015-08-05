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

  module.exports.maybeUseCache username, size, res, (err) ->
    return next err  if err?

    onError = (err) ->
      return res.redirect defaultUrl  if defaultUrl?
      next err

    onResponse = (response) ->
      file = fs.createWriteStream "#{cacheDir}/#{username}.jpg"
      response.pipe(file).on 'close', () ->
        module.exports.resizeCache username, size, (err) ->
          return next err  if err?
          module.exports.maybeUseCache username, size, res, (err) ->
            return next err  if err?
            return res.redirect defaultUrl  if defaultUrl?
            return res.status(404).send()

    request.get({url: "http://example.com/#{username}.jpg"}) # CHANGEME
      .on('error', onError)
      .on('response', onResponse)

module.exports.maybeUseCache = (username, size, res, next) ->
  if fs.existsSync "#{cacheDir}/#{username}.#{size}.jpg"
    return res.sendFile "#{cacheDir}/#{username}.#{size}.jpg"
  else if fs.existsSync "#{cacheDir}/#{username}.jpg"
    module.exports.resizeCache username, size, (err) ->
      return next err  if err?
      return res.sendFile "#{cacheDir}/#{username}.#{size}.jpg"
  else
    next()

module.exports.resizeCache = (username, size, next) ->
  lwip.open "#{cacheDir}/#{username}.jpg", (err, image) ->
    return next err  if err?

    width = image.width()
    height = image.height()
    refSize = Math.min width, height

    scaleRatio = 1
    if refSize > size
      scaleRatio = Math.ceil(size / refSize * 100) / 100

    image.batch()
      .scale(scaleRatio)
      .crop(size, size)
      .writeFile "#{cacheDir}/#{username}.#{size}.jpg", next
