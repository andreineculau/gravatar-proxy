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
  subpath: '/avatar'       # host gravatar under a subpath
  morgan:                  # logging https://github.com/expressjs/morgan
    format: 'common'
  getAvatarFun: require './getAvatar.default'
  allowUnknownHashes: true
  knownHashesFilename: 'hash2email.json'
}
