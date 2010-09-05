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
    client.query query, real_vals, ret
   
  q: (query, vals, ret) ->
      client.query query, vals, ret
      
  update: (table, obj, the_where, ret) ->
    sets = []
    real_vals = []
    _.each obj, (val, key) ->
      sets.push "`#{key}` = ?, "
      real_vals.push val
    sets = sets.join ""
    sets = _.s sets, 0, -2
    
    wheres = []
    _.each the_where, (val, key) ->
      wheres.push "`#{key}` = ? and "
      real_vals.push val
    wheres = wheres.join ""
    wheres = _.s wheres, 0, -(" and ".length) #removeing last 'and'
    query = "UPDATE #{table} SET #{sets} WHERE #{wheres}"
    client.query query, real_vals, ret
