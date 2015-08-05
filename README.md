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

You can see an example in [getAvatar.redirect.coffee](getAvatar.redirect.coffee),
assuming that your `config.coffee` looks like this

```coffee
  getAvatar: require './getAvatar.redirect'
  allowUnknownHashes: false
```

In order to make an email (its hash) known, just `POST /?email=user@example.com`.

If you want to create aliases, just `PUT /<hash_for_user@foo.com>?email=user@example.com`

## License

[Apache 2.0](LICENSE)
