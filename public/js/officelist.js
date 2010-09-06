(function() {
  var add_google_map_marker, add_search_result, bubbles, current_listing, map, markers, remove_markers, rpc, user;
  user = "";
  current_listing = "";
  bubbles = [];
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
  add_search_result = function(listing) {
    var marker;
    marker = new google.maps.Marker({
      position: new google.maps.LatLng(listing.lat, listing.lng),
      map: map
    });
    if (listing.user === user) {
      marker.setDraggable(true);
    }
    return google.maps.event.addListener(marker, "click", function() {
      var bubble;
      bubble = new google.maps.InfoWindow({
        content: ("\
      [image]\
      <br>\
      <h3>" + (listing.location) + "</h3>\
      <div>\
      " + (listing.description || "") + "\
      </div>\
      ")
      });
      bubble.open(map, marker);
      if (listing.user === user) {
        $("h3.edit_listing").click();
        $(".edit_listing [name='location']").val(listing.location);
        $(".edit_listing [name='size']").val(listing.size);
        $(".edit_listing [name='price']").val(listing.price);
        $(".edit_listing [name='price_type']").val(listing.price_type);
        $(".edit_listing [name='price_type']").val(listing.price_type);
        $(".edit_listing [name='nnn']").val(listing.nnn);
        $(".edit_listing [name='description']").val(listing.description);
        $(".edit_listing [name='built']").val(listing.built);
        current_listing = listing.id;
        return (markers = [marker]);
      }
    });
  };
  $(document).ready(function() {
    var button, initialize, interval, the_height;
    user = $("#user").attr("data-officelist-user");
    initialize = function() {
      var latlng, myOptions;
      latlng = new google.maps.LatLng(33.4222685, -111.8226402);
      myOptions = {
        zoom: 11,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      map = new google.maps.Map(document.getElementById("map"), myOptions);
      return rpc("get_all_listings", {}, function(data) {
        return _.each(data, function(listing) {
          return add_search_result(listing);
        });
      });
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
    $("#add_form").submit(function(e) {
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
        rpc("add_listing", data, function(ret) {
          var listing;
          alert("listing added");
          listing = {};
          _.each(data, function(item) {
            return (listing[item.name] = item.value);
          });
          listing.id = ret.result.insertId;
          listing.user = user;
          add_search_result(listing);
          remove_markers();
          return console.log("added", listing);
        });
        e.preventDefault();
        return false;
      } catch (e) {
        alert(e);
        return false;
      }
    });
    $("#edit_form").submit(function(e) {
      var data, lat, lat_lng, lng;
      try {
        data = $("#edit_form").serializeArray();
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
        data.push({
          name: "id",
          value: current_listing
        });
        rpc("edit_listing", data, function() {
          return alert("listing edited");
        });
        e.preventDefault();
        return false;
      } catch (e) {
        alert(e);
        return false;
      }
    });
    $(".multi").MultiFile();
    button = $("#add_upload");
    interval = 0;
    return new AjaxUpload(button, {
      action: "/upload",
      name: "myfile",
      onSubmit: function(file, ext) {
        button.text("Uploading");
        this.disable();
        return (interval = window.setInterval(function() {
          var text;
          text = button.text;
          return text.length < 13 ? button.text(text + ".") : button.text("Uploading...");
        }, 200));
      },
      onComplete: function(file, response) {
        console.log(response);
        button.text("Add Another");
        window.clearInterval(interval);
        this.enable();
        return $('<div></div>').appendTo('#add_files_list').text(file);
      }
    });
  });
})();
