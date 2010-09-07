this.methods = 
  add_listing: (req, res) ->
    obj = ["built", "location", "nnn", "price", "price_type", "size", "type", "lat", "lng", "description"]
    insert = {}
    insert.user = req.officelistUser()
    _.each obj, (val) ->
      insert[val] = req.param(val) or ""
      
    data.insert "listings", insert, (error, results, fields) ->
      if req.body.images
        inserts = []
        _.each req.body.images, (url) ->
          inserts.push [results.insertId, url]
        data.insertMany "images", ["listing", "url"], inserts, (image_error, image_results, image_fields) ->        
          res.send
            result: results
            id: fields
            error: error
        
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

