this.methods = 
  add_listing: (req, res) ->
    obj = ["built", "location", "nnn", "price", "price_type", "size", "type", "lat", "lng"]
    insert = {}
    insert.user = req.officelistUser()
    _.each obj, (val) ->
      insert[val] = req.param(val) or ""
      
    data.insert "listings", insert, (error, results, fields) ->
      res.send
        result: results
        id: fields
        error: error


