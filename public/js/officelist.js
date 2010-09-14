(function() {
  var add_google_map_marker, add_search_result, bubbles, current_listing, is_webkit, map, map_move_listener, markers, move_video_when_map_moves, remove_markers, rpc, user, vid_height, vid_width;
  user = "";
  current_listing = "";
  bubbles = [];
  is_webkit = function() {
    return navigator.userAgent.match(/webkit/i);
  };
  vid_height = 344;
  vid_width = 425;
  rpc = function(method, params, good) {
    return $.ajax({
      type: "POST",
      url: "/methods/" + method,
      data: params,
      success: good,
      error: function(e) {
        alert(e.status);
        return alert(e.responseText);
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
  map_move_listener = "";
  move_video_when_map_moves = function() {
    return (map_move_listener = google.maps.event.addListener(map, 'center_changed', function() {
      return $('#current_video').css({
        top: $('#video_position').offset().top,
        left: $('#video_position').offset().left
      });
    }));
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
      var bubble, info, vid;
      info = $("<div style='width: 500px; height: 500px;'><br /></div>");
      if ("default_youtube" in listing) {
        console.log("has youtube");
        if (is_webkit()) {
          vid = $("<div id='current_video'></div>");
          vid.append(listing.default_youtube);
          vid.css({
            position: "absolute"
          });
          $(document.body).append(vid);
          info.append($("<div id='video_position'>Hi</div>"));
          move_video_when_map_moves();
        } else {
          info.append(listing.default_youtube);
        }
      } else if ("default_image" in listing) {
        info.append("<img src=\"" + (listing.default_image) + "\" />");
      }
      info.append("<table>\n  <tr>\n    <td width=\"70%\" valign=\"top\">\n      <h3>test " + (listing.location) + "</h3>\n      <div>" + (listing.description) + "</div>\n    <td>\n    <td width=\"30%\" valign=\"top\">\n      " + (listing.price) + " " + (listing.price_type) + "\n      <br>\n      " + (listing.size) + "\n      " + (listing.built) + " " + (listing.type) + "\n    <td>\n  </tr>\n</table>");
      bubble = new google.maps.InfoWindow({
        content: info[0]
      });
      _.each(bubbles, function(bubble) {
        return bubble.close();
      });
      bubbles = [];
      bubbles.push(bubble);
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
    var add_image_count, add_youtube_count, button, initialize, interval, the_height;
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
          if ("youtubes" in ret.result) {
            listing.youtube_htmls = ret.result.youtubes;
            if (ret.result.youtubes.length > 0) {
              listing.default_youtube = ret.result.youtubes[0];
            }
          }
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
    add_image_count = 0;
    add_youtube_count = 0;
    new AjaxUpload(button, {
      action: "/upload-image",
      name: "myfile",
      onSubmit: function(file, text) {
        button.text("Uploading");
        return this.disable();
      },
      onComplete: function(file, response) {
        var input;
        input = $("<input type='hidden'>");
        input.val("/images/medium/" + response);
        input.attr("name", "images[" + (add_image_count) + "]");
        $("#add_form").append(input);
        add_image_count += 1;
        button.text("Add Another");
        window.clearInterval(interval);
        this.enable();
        return $('<img style="display: block; margin: 3px;">').appendTo('#add_files_list').attr("src", "/images/thumbs/" + (response));
      }
    });
    return $("#add_youtube").click(function(e) {
      var a, input;
      input = $("<input class='youtube_inupt' type='text'>");
      add_youtube_count += 1;
      input.attr("name", "youtube[" + add_youtube_count + "]");
      a = $("<a href='#'>Remove</a>");
      a.click(function(e) {
        $(this).prev().remove();
        $(this).remove();
        return false;
      });
      $("#add_youtube_box").append(input).append(a);
      return false;
    });
  });
})();
