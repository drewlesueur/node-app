this.data = 
  insert: (table, obj, ret) ->
    fields = []
    vals = []
    real_vals = []
    _.each obj, (val, key) ->
      fields.push "`#{key}`, "
      vals.push "?, "
      real_vals.push val
    fields = fields.join "" #join fields
    fields = _.s fields, 0, -2 #remove trailing comma
    vals = vals.join ""
    vals = _.s vals, 0, -2 # remove trailing comma
    query = "INSERT INTO #{table} (#{fields}) VALUES (#{vals})"
    client.query query, real_vals, (error, results, fields) ->
      console.log client.lastQuery
      ret error, results, fields
    
      

