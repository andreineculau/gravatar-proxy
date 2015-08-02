fs = require 'fs'
parseurl = require 'parseurl'
pkg = require './package.json'

module.exports = {
  pkg
  listenOn: [
    protocol: 'http'
    module: 'http'
    hostname: '0.0.0.0'
    port: 3000
    options: undefined     # options for module.createServer
    headers:               # extra headers
      'Cache-Control': 'no-cache, no-store, must-revalidate'
      'Pragma': 'no-cache'
      'Expires': '0'
      'Server': "#{pkg.name}/#{pkg.version}"
  ],
  subpath: '/'             # host gravatar under a subpath
  morgan:                  # logging https://github.com/expressjs/morgan
    format: 'common'
  getAvatarFun: (req, res, next) ->
    {email, hash} = req.params
    switch req.protocol
      when 'http'
        {query} = parseurl req
        res.redirect "http://www.gravatar.com/avatar/#{hash}?#{query}"
      when 'https'
        res.redirect "https://secure.gravatar.com/avatar/#{hash}?#{query}"
      else
        res.status(404).send()
  allowUnknownHashes: true
  knownHashesFilename: 'hash2email.json'
}
