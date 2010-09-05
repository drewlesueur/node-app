(function() {
  var add_google_map_marker, map, markers, remove_markers;
  map = "";
  markers = [];
  remove_markers = function() {
    var _a, _b, _c, _d, i;
    _a = []; _c = markers;
    for (_b = 0, _d = _c.length; _b < _d; _b++) {
      i = _c[_b];
      _a.push(i.setMap(null));
    }
    return _a;
  };
  add_google_map_marker = function(wherethe) {
    var geocoder;
    remove_markers();
    geocoder = new google.maps.Geocoder();
    return geocoder.geocode({
      address: wherethe
    }, function(results, status) {
      var marker;
      if (status === google.maps.GeocoderStatus.OK) {
        map.setCenter(results[0].geometry.location);
        marker = new google.maps.Marker({
          position: results[0].geometry.location,
          map: map,
          title: "hello world",
          draggable: true
        });
        return markers.push(marker);
      } else {
        return alert("Geocode was not successful for the following reason: " + status);
      }
    });
  };
  $(document).ready(function() {
    var initialize, the_height;
    initialize = function() {
      var latlng, myOptions;
      latlng = new google.maps.LatLng(33.4222685, -111.8226402);
      myOptions = {
        zoom: 11,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      return (map = new google.maps.Map(document.getElementById("map"), myOptions));
    };
    initialize();
    $('#main_table').css({
      height: $(window).height() + "px"
    });
    the_height = $("#map").parent().height() + "px";
    console.log(the_height);
    $("#map").css({
      height: the_height
    });
    $("#left_side").accordion({
      autoHeight: false
    });
    return $("#location").change(function(e) {
      console.log("location change");
      return add_google_map_marker($(this).val());
    });
  });
})();
