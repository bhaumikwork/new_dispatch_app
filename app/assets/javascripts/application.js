// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.validate
//= require turbolinks
//= require_tree .
	var curr_lat;
	var curr_long;
	var options = { enableHighAccuracy: true, maximumAge: 100, timeout: 60000 };
	function showPosition(position) {
		console.log(position.coords);
		curr_lat = position.coords.latitude;
		curr_long = position.coords.longitude;
	}
	function getLocation() {
    if (navigator.geolocation) {
    	console.log('in geolocation');
    	navigator.geolocation.watchPosition(showPosition,positionError,options);
    } else {
       alert("Geolocation is not supported by this browser.");
    }
	}
	function positionError() {
		console.log("error");
    $('.error').html('You have not clicked on allow button to share your location. So we can not track the current location. It will not work.')
	}

Number.prototype.between = function(a, b) {
  var min = Math.min.apply(Math, [a, b]),
    max = Math.max.apply(Math, [a, b]);
  return this > min && this < max;
};