Auth = require "auth"
fs = require "fs"

#for twitter
config =
  consumerKey: ""
  consumerSecret: ""


express = require("express")
app = express.createServer()

app.configure () ->
  app.set("root", __dirname)
  app.set('views', __dirname + '/views')
  # app.use(express.logger())
  app.use(express.staticProvider("public"))
  console.log(__dirname)
  app.use(express.methodOverride())
  app.use(express.bodyDecoder())
  app.use(express.cookieDecoder())
  app.use(express.session({ lifetime: (150).seconds, reapInterval: (10).seconds }))
  app.use(Auth([ Auth.Anonymous(), Auth.Never(), Auth.Twitter(config) ]))

app.get "/", (req, res) ->
  if req.isAuthenticated()
    res.render 'home2.jade', layout: false, locals:
      username: req.getAuthDetails().user.username
  else
    res.render 'home2.jade', layout: false, locals:
      username: ""


app.get '/auth/twitter/callback', (req, res, params) ->
  req.authenticate ['twitter'], (error, authenticated) ->
    res.writeHead(200, {'Content-Type': 'text/html'})
    if authenticated
      console.log "user login " +  JSON.stringify req.getAuthDetails()
      console.log req.session.access_token
      res.redirect "/"
    else
      res.redirect "http://google.com"

app.get '/coffee/:name.js', (req, res) ->
  exec "coffee -c public/js/" + req.params.name + '.coffee', (error, stdout, stderr) ->
    console.log(error)
    fs.chmod 'public/js/' + req.params.name + '.js', parseInt("777", 8), () ->
      res.sendfile('public/js/' + req.params.name + '.js')

app.get "/logout", (req, res, params) ->
  req.logout()
  res.redirect "/"

exports.run = () ->
  app.listen parseInt(process.env.PORT or 86), null
