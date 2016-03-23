var system = require('system');
var args = system.args;
var page = require('webpage').create();
console.log("screen_capture in js");
console.log(args[1]);
try {
	page.open("https://google.co.in", function() {
	// page.open('http://dispatcher-stagging.herokuapp.com/load_map/blfi7', function() {
		try{
			page.render('./public/assets/'+args[1]+'.png');
		  console.log("image generated at ",'./public/assets/'+args[1]+'.png');
		  phantom.exit();
		} catch(x) {
			console.log(x);
		}
	});
} catch(e){
	console.log(e);
}

