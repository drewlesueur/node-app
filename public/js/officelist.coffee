user = ""
current_listing = ""
bubbles = []

vid_height = 344
vid_width = 425

rpc = (method, params, good) ->
  $.ajax
    type: "POST"
    url: "/methods/" + method
    data: params
    success: good
    error: (e) -> 
      # for x of e
      alert e.status
      alert e.responseText

map = ""
markers = []  

remove_markers = () ->
  for i in markers
    i.setMap null
    
add_google_map_marker = (wherethe) ->
  remove_markers()
  geocoder = new google.maps.Geocoder()
  geocoder.geocode address: wherethe, (results, status) ->
    if status is google.maps.GeocoderStatus.OK
      map.setCenter results[0].geometry.location
      marker = new google.maps.Marker
        position: results[0].geometry.location
        map: map
        title: "hello world"
        draggable: true
      markers.push marker

    else
      alert "Geocode was not successful for the following reason: " + status
 
add_search_result = (listing) ->
  marker = new google.maps.Marker
    position: new google.maps.LatLng listing.lat, listing.lng
    map: map
  if listing.user is user
    marker.setDraggable true
  google.maps.event.addListener marker, "click", () ->    
    #info = $("<div style='width: 500px;'><br /></div>")
    
    if "default_youtube" of listing
      
      # webkit doesn't like this, have to use iframe
      #info.append listing.default_youtube
      ##info.find("object").css position: "absolute"
      
      console.log listing.default_youtube
      
      info = '<div id="popup"><object data="http://www.youtube.com/v/kEBXrtKO-g4" style="width: 425px; height: 350px;" type="application/x-shockwave-flash"><param value="http://www.youtube.com/v/kEBXrtKO-g4" name="movie"></object></div>'
      #info = '<div style="position: absolute; left: 16px; top: 16px; width: 441px; height: 371px; z-index: 10;"><div><div id="popup"><object data="http://www.youtube.com/v/kEBXrtKO-g4" style="width: 425px; height: 350px;" type="application/x-shockwave-flash"><param value="http://www.youtube.com/v/kEBXrtKO-g4" name="movie"></object></div></div></div>'
      
      
      """
      framer = $("<iframe src='/empty.html' width='#{vid_width}' height='400' scrollbars='no'><iframe>")
      framer.css 
        border: "none"
      $(framer).load () ->
        $(framer).contents().find("body").append listing.default_youtube
        $(framer).contents().find("object").css 
          position: "absolute"
          top: "00px"
      info.append framer
      """
      
      
    else if "default_image" of listing
      info.append """
      <img src="#{listing.default_image}" />
      """
    
    #info.append("""
    
    ("""<table>
      <tr>
        <td width="70%" valign="top">
          <h3>test #{listing.location}</h3>
          <div>#{listing.description}</div>
        <td>
        <td width="30%" valign="top">
          #{listing.price} #{listing.price_type}
          <br>
          #{listing.size}
          #{listing.built} #{listing.type}
        <td>
      </tr>
    </table>
    """)
    
    
    bubble = new google.maps.InfoWindow
      content: info
      
    _.each bubbles, (bubble) ->
      bubble.close()
    bubbles = []
    bubbles.push bubble
    bubble.open map, marker
    if listing.user is user
      $("h3.edit_listing").click()
      $(".edit_listing [name='location']").val(listing.location)
      $(".edit_listing [name='size']").val(listing.size)
      $(".edit_listing [name='price']").val(listing.price)
      $(".edit_listing [name='price_type']").val(listing.price_type)
      $(".edit_listing [name='price_type']").val(listing.price_type)
      $(".edit_listing [name='nnn']").val(listing.nnn)
      $(".edit_listing [name='description']").val(listing.description)
      $(".edit_listing [name='built']").val(listing.built)
      current_listing = listing.id
      markers = [marker]
      
    

$(document).ready () ->
  user = $("#user").attr "data-officelist-user"
  initialize = () ->
    latlng = new google.maps.LatLng(33.4222685, -111.8226402)
    myOptions = {
      zoom: 11,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById("map"),myOptions)
    
    rpc "get_all_listings", {},(data) ->
      _.each data, (listing) ->
        add_search_result listing
    
  initialize()
  
  #make th table the right height
  $('#main_table').css
    height: $(window).height() + "px"
  
  the_height = $("#map").parent().height() + "px"
  
  
  # make the map the right height
  $("#map").css
    height: the_height
    
  $("#left_side").accordion autoHeight: false
    
  $("#location").change (e) ->
    add_google_map_marker $(this).val()
    
  $("#add_form").submit (e) ->
    try
      data = $("#add_form").serializeArray()
      if markers.length is 0
        $("#location").change()
      lat_lng = markers[0].getPosition()
      lat = lat_lng.lat()
      lng = lat_lng.lng()
      data.push name: "lat", value: lat
      data.push name: "lng", value: lng
      rpc "add_listing", data, (ret) ->
        alert "listing added"
        listing = {}
        _.each data, (item) ->
          listing[item.name] = item.value
        listing.id = ret.result.insertId
        if "youtubes" of ret.result
          listing.youtube_htmls = ret.result.youtubes
          if ret.result.youtubes.length > 0
            listing.default_youtube = ret.result.youtubes[0]
        listing.user = user
        add_search_result listing
        remove_markers() #remove the adding markers
        console.log "added", listing
      e.preventDefault()
      return false
    catch e
      alert e
      return false
      
  $("#edit_form").submit (e) ->
    try
      data = $("#edit_form").serializeArray()
      lat_lng = markers[0].getPosition()
      lat = lat_lng.lat()
      lng = lat_lng.lng()
      data.push name: "lat", value: lat
      data.push name: "lng", value: lng
      data.push name: "id", value: current_listing
      rpc "edit_listing", data, () ->
        alert "listing edited"
      e.preventDefault()
      return false
    catch e
      alert e
      return false
   
          
  $(".multi").MultiFile()
  
  button = $("#add_upload")
  interval = 0;
  add_image_count = 0
  add_youtube_count = 0
  
  new AjaxUpload button,
    action: "/upload-image"
    name: "myfile"
    onSubmit : (file, text) ->
      button.text "Uploading"
      this.disable()
    onComplete: (file, response) ->
      input = $("<input type='hidden'>")
      input.val("/images/medium/" + response)
      input.attr "name", "images[#{add_image_count}]"
      $("#add_form").append input
      add_image_count += 1
      button.text "Add Another"
      window.clearInterval interval
      this.enable()
      $('<img style="display: block; margin: 3px;">').appendTo('#add_files_list').attr "src", "/images/thumbs/#{response}"
        
    
      
  $("#add_youtube").click (e) ->    
      input = $("<input class='youtube_inupt' type='text'>")
      add_youtube_count  += 1
      input.attr "name", "youtube[" + add_youtube_count + "]"
      a = $("<a href='#'>Remove</a>")
      a.click (e) ->
        $(this).prev().remove()
        $(this).remove()
        return false
        
      $("#add_youtube_box").append(input).append(a)
      
      return false
    