this.methods = 
  add_listing: (req, res) ->
    obj = ["built", "location", "nnn", "price", "price_type", "size", "type", "lat", "lng", "description"]
    insert = {}
    insert.user = req.officelistUser()
    _.each obj, (val) ->
      insert[val] = req.param(val) or ""
      
    data.insert "listings", insert, (error, results, fields) ->
      
      # you are adding images and youtube
      # this is where mongodb would be helpful.
      # you could just create the json object and add it.
      # next project use mongodb
      # your posts would not be url encoded. they would just be json strings
      
      images_done = false
      youtube_done = false
      
      done = () ->
        if images_done and youtube_done
          res.send
            result: results
            error: error
      if req.body.images
        inserts = []
        _.each req.body.images, (url) ->
          inserts.push [results.insertId, url] 
        data.insertMany "images", ["listing", "url"], inserts, (image_error, image_results, image_fields) ->        
          images_done = true
          done()
      else
        images_done = true
          
      if req.body.youtube
        inserts = []
        _.each req.body.youtube, (url) ->
          inserts.push [results.insertId, url]
        data.insertMany "youtube", ["listing", "url"], inserts, (youtube_error, youtube_results, youtube_fields) ->          
          youtube_done = true
          done()
      else
        youtube_done = true
        
      done()
            
            
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
            console.log obj.url.indexOf "#p"
            console.log """
            
            you found p in #{obj.url}
            
            """
            url = obj.url.split "/"
            url = _.s url, -1
            obj.url = "http://www.youtube.com/watch?v=#{url}"
            console.log "new url for #{obj.id} is #{obj.url}"
          
          request uri: "http://www.youtube.com/oembed?url=#{encodeURIComponent(obj.url)}&format=json", (err, response, body) ->
            accounted_for += 1
            console.log "yaaay"
            if not err and response.statusCode is 200
              ret.push obj.url + " " + body
            else
              ret.push obj.url + " bad"
            if accounted_for is results.length
              youtubes = ret
              done()
        done()        
          #ret.push obj.url  
      done()
      
      
