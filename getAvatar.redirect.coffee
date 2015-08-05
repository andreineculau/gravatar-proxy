module.exports = (req, res, next) ->
  email = req.params.email
  [username, domain] = email.split '@'
  res.redirect "//example.com/#{username}.jpg" # CHANGEME
