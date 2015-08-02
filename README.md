# Gravatar proxy

A gravatar proxy for your intranet

## Install and run

```sh
git clone git://github.com/andreineculau/gravatar-proxy.git
cd gravatar-proxy
npm install
# edit config.coffee as you see fit
npm start
```

Here's what you can configure out-of-the-box: [config.coffee](config.coffee).

In production, try

* [forever](https://github.com/foreverjs/forever)
* [upstarter](https://github.com/carlos8f/node-upstarter)
* ...

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/andreineculau/gravatar-proxy)

## Common setup

By default, gravatar-proxy will, well.. proxy requests straight to gravatar.com .

But a common setup is that you have some server that hosts the avatars and you
just want a proxy to tie up the MD5 hashes to the usernames, and maybe also
restrict the email addresses to those that are known to your group.

Change your `config.coffee` to this

```coffee
  getAvatar: (req, res, next) ->
    email = req.params.email
    [username, domain] = email.split '@'
    res.redirect "//example.com/#{username}.jpg"
  allowUnknownHashes: false
```

## License

[Apache 2.0](LICENSE)
