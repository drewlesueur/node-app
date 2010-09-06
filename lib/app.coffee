require "./secret.coffee"

Client = require('mysql').Client
client = new Client()
client.user = data_config.user
# client.host = '127.0.0.1'
client.password = data_config.password
client.connect()
client.query('USE officelist');


this.client = client

Auth = require "auth"
fs = require "fs"
require ("./underscore")
require("./util")
require("./util2.coffee")
require("./methods")



form = require "connect-form"
express = require("express")
app = express.createServer()



MyTest = (req, res, next) ->
  req.party = "have a party"
  res.party = "have a double time party"
  if not req.session.officelist
    req.session.officelist = {}

  req.officelistUser = () ->
    return req.session.officelist.userdomain + ":" + req.session.officelist.userid
  
  next()


app.configure () ->
  app.set("root", __dirname)
  app.set('views', __dirname + '/views')
  # app.use(express.logger())
  app.use(express.staticProvider("public"))
  # console.log(__dirname)
  app.use(express.methodOverride())
  app.use(express.bodyDecoder())
  app.use(express.cookieDecoder())
  app.use(express.session({ lifetime: (150).seconds, reapInterval: (10).seconds }))
  app.use(Auth([ Auth.Anonymous(), Auth.Never(), Auth.Twitter(twitter_config) ]))
  app.use MyTest
  app.use form(keepExtensions: true)


# take and image upload it and return the address for the thumbnail
app.post "/upload-image", (req, res) ->
  req.form.complete (err, fields, files) ->
    if err
      res.send("error")
    if files
      file_name = files.myfile.path.split "/"
      file_name = _.s file_name, -1
      output_file = "public/images/thumbs/#{file_name}"
      exec "convert #{files.myfile.path} -resize 50x50 #{output_file}", (err, stdin, stdout) ->
        medium_output_file = "public/images/medium/#{file_name}"
        exec "convert #{files.myfile.path} -resize 450x450 #{medium_output_file}", (err, stdin, stdout) ->
          res.send _.s(output_file, "public".length) #get rid of public from the string
        
        
      #res.send(JSON.stringify files)
 
 
app.get "/", (req, res) ->
  if req.isAuthenticated()
    
    res.render 'home2.jade', layout: false, locals:
      username: req.getAuthDetails().user.username
      req: req
      res: res
  else
    # console.log "having a what?: " + req.party
    res.render 'home2.jade', layout: false, locals:
      username: ""
      req: req
      res: res

app.post "/methods/:method", (req, res) ->
  methods[req.param("method")] req, res
    



app.get '/auth/twitter/callback', (req, res, params) ->
  
  if _(req.headers.host).startsWith "localhost"
    authentication_strategy = "anon"
  else
    authentication_strategy = "twitter"
  req.authenticate [authentication_strategy], (error, authenticated) ->
    res.writeHead(200, {'Content-Type': 'text/html'})
    if authenticated
      req.session.officelist.userdomain = authentication_strategy
      if authentication_strategy is "twitter"
        req.session.officelist.userid = req.getAuthDetails().user.userid
      else if authentication_strategy is "anon"
        req.session.officelist.userid = req.getAuthDetails().user.username
      # console.log "user login " +  JSON.stringify req.getAuthDetails()
      # console.log req.session.access_token
      res.redirect "/"
    else
      res.redirect "/"

app.get '/coffee/:name.js', (req, res) ->
  exec "coffee -c public/js/" + req.params.name + '.coffee', (error, stdout, stderr) ->
    if error
      console.log(error)
    fs.chmod 'public/js/' + req.params.name + '.js', parseInt("777", 8), () ->
      res.sendfile('public/js/' + req.params.name + '.js')

app.get "/logout", (req, res, params) ->
  req.logout()
  res.redirect "/"

exports.run = () ->
  app.listen parseInt(process.env.PORT or 8889), null
