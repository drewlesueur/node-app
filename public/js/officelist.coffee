map = ""
  
add_google_map_marker = (where) ->
  geocoder = new google.maps.Geocoder()
  geocoder.geocode address: where, (results, status) ->
    if status is google.maps.GeocoderStatus.OK
      map.setCenter resutls[0].geometry.location
        marker = new google.maps.Marker
          position: results[0].geometry.location
          map: map
          title: "hello world"
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
  console.log the_height
  
  # make the map the right height
  $("#map").css
    height: the_height
    
  $("#left_side").accordion autoHeight: false
    
  $("#location").change (e) ->
    console.log "location change"
    add_google_map_marker $(this).val()
    
    
    
    
  
 
  
