(function() {
  $(document).ready(function() {
    var initialize, the_height;
    initialize = function() {
      var latlng, map, myOptions;
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
    return $("#left_side").accordion({
      autoHeight: false
    });
  });
})();
