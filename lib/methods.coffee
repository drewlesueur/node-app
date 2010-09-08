this.methods = 
  add_listing: (req, res) ->
    obj = ["built", "location", "nnn", "price", "price_type", "size", "type", "lat", "lng", "description"]
    
    insert = {}
    insert.user = req.officelistUser()
    _.each obj, (val) ->
      insert[val] = req.param(val) or ""
    
    if "images" of req.body
      insert.default_image = req.body.images[0] or ""
    
    data.insert "listings", insert, (error, results, fields) ->
      
      # you are adding images and youtube
      # this is where mongodb would be helpful.
      # you could just create the json object and add it.
      # next project use mongodb
      # your posts would not be url encoded. they would just be json strings
      
      do_images = (done) ->      
        if req.body.images
          inserts = []
          _.each req.body.images, (url) ->
            inserts.push [results.insertId, url] 
          data.insertMany "images", ["listing", "url"], inserts, (image_error, image_results, image_fields) ->        
            done()
        else
          done()
      
      do_youtube = (done) ->
        if req.body.youtube
          inserts = []
          get_youtube_embed req.body.youtube, (embed) ->
            inserts = []
            _.each req.body.youtube, (url, key) -> 
              inserts.push [results.insertId, url, embed[key]]
            data.insertMany "youtube", ["listing", "url", "html"], inserts, (youtube_error, youtube_results, youtube_fields) ->          
              done(embed)
        else
          done()
      
      
      _.do_these [do_images, do_youtube], (ret) ->
        finish = (youtubes) -> #adding the youtube html code to the result
          if youtubes
            results.youtubes = youtubes
          res.send
            result: results
            error: error
        youtubes = ret[1]
        found = false
        if youtubes and (0 of youtubes)
          for html in youtubes
            if html isnt ""
              found = true
              insert = default_youtube: html
              the_where = id: results.insertId
              data.update "listings", insert, the_where, () ->
                finish(youtubes)
              break
          if found is false
            finish()
        else
          finish()
          
            
  get_all_listings: (req, res) ->
    data.q "select * from listings", (error, results) ->
      res.send results
     
  edit_listing: (req, res) ->
    obj = ["built", "location", "nnn", "price", "price_type", "size", "type", "lat", "lng", "description"]
    insert = {}
    _.each obj, (val) ->
      insert[val] = req.param val
    the_where = 
      user: req.officelistUser()
      id: req.param "id"
    data.update "listings", insert, the_where, (error, results) ->
      res.send
        result: results
        id: ""
        error: error

  get_listing_images: (req, res) ->
    
    images = false
    youtubes = false
    
    done = () ->
      if images and youtubes
        res.send
          images: images
          youtubes: youtubes
          
    data.q "select url from images where listing = ?", [req.param("id")], (error, results) ->
      if error
        res.send error
      else
        ret = []
        _.each results, (obj) ->
          ret.push obj.url  
        images = ret
      done()
    
    data.q "select url, id from youtube where listing = ?", [req.param("id")], (error, results) ->
      if error
        res.send error
      else
        ret = []
        if results.length is 0
          youtubes = []
          done()
        accounted_for = 0;
        _.each results, (obj) ->
          if obj.url.indexOf("#p") != -1
            url = obj.url.split "/"
            url = _.s url, -1
            obj.url = "http://www.youtube.com/watch?v=#{url}"
          
          request uri: "http://www.youtube.com/oembed?url=#{encodeURIComponent(obj.url)}&format=json", (err, response, body) ->
            accounted_for += 1
            if not err and response.statusCode is 200
              ret.push JSON.parse(body)
            else
              1 == 1
            if accounted_for is results.length
              youtubes = ret
              done()
        done()        
          #ret.push obj.url  
      done()
      
      

get_youtube_embed = (urls, done) ->
  #return done(urls)
  make_the_request = (url, done) ->
    if url.indexOf("#p") != -1
      url = url.split "/"
      url = _.s url, -1
      url = "http://www.youtube.com/watch?v=#{url}"
    request uri: "http://www.youtube.com/oembed?url=#{encodeURIComponent(url)}&format=json", (err, response, body) ->
      if not err and response.statusCode is 200
        done(JSON.parse(body).html)
      else
        done("yowser")
  todos = ((done) -> make_the_request(url, done)) for key, url of urls
  
  _.do_these todos, (ret) ->
    done ret
  
#get_youtube_embed = (urls, done) ->
#  ret = []
#  accounted_for = 0;
#  if urls.length is 0
#    done(ret)
#  _.each urls, (url) ->
#    if url.indexOf("#p") != -1
#      url = url.split "/"
#      url = _.s url, -1
#      url = "http://www.youtube.com/watch?v=#{url}"
#    request uri: "http://www.youtube.com/oembed?url=#{encodeURIComponent(obj.url)}&format=json", (err, response, body) ->
#      accounted_for += 1
#      if not err and response.statusCode is 200
#        ret.push JSON.parse(body)
#      if accounted_for is results.length
#       done(ret)