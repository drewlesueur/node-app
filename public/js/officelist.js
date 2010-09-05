(function() {
  var add_google_map_marker, map, markers, remove_markers, rpc;
  rpc = function(method, params, good) {
    return $.ajax({
      type: "POST",
      url: "/methods/" + method,
      data: params,
      success: good,
      error: function() {
        return alert("oops");
      }
    });
  };
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
    $("#map").css({
      height: the_height
    });
    $("#left_side").accordion({
      autoHeight: false
    });
    $("#location").change(function(e) {
      return add_google_map_marker($(this).val());
    });
    return $("#add_form").submit(function(e) {
      var data, lat, lat_lng, lng;
      try {
        data = $("#add_form").serializeArray();
        if (markers.length === 0) {
          $("#location").change();
        }
        lat_lng = markers[0].getPosition();
        lat = lat_lng.lat();
        lng = lat_lng.lng();
        data.push({
          name: "lat",
          value: lat
        });
        data.push({
          name: "lng",
          value: lng
        });
        rpc("add_listing", data, function() {
          return alert("listing added");
        });
        e.preventDefault();
        return false;
      } catch (e) {
        alert(e);
        return false;
      }
    });
  });
})();
