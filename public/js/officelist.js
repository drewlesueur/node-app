(function() {
  $(document).ready(function() {
    var initialize;
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
    return console.log('lized');
  });
})();
