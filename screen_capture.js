var system = require('system');
var args = system.args;
var page = require('webpage').create();
console.log("screen_capture in js");
console.log(args[1]);
page.open('http://dispatcher-stagging.herokuapp.com/load_map/'+args[1], function() {
  page.render('public/location_detail/'+args[1]+'.png');
  phantom.exit();
});

