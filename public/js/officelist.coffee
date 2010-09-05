rpc = (method, params, good) ->
  $.ajax
    type: "POST"
    url: "/methods/" + method
    data: params
    success: good
    error: () -> alert "oops"

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
 
  

$(document).ready () ->
  initialize = () ->
    latlng = new google.maps.LatLng(33.4222685, -111.8226402)
    myOptions = {
      zoom: 11,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById("map"),myOptions)
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
      rpc "add_listing", data, () ->
        alert "listing added"
      e.preventDefault()
      return false
    catch e
      alert e
      return false
        
          
        
        
    
      
      
      
      
    
   
    
