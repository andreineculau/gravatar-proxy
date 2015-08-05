module.exports = (req, res, next) ->
  {email, hash} = req.params
  {query} = parseurl req
  return res.redirect "//www.gravatar.com/avatar/#{hash}?#{query}"
