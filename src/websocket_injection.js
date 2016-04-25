console.log('Injected script is running');
var ws = new WebSocket('ws://localhost:9090', Array());
ws.onmessage = function (e){
	console.log (e.data);

	var links = document.getElementsByTagName("link");
	for (var x in links) {
		var link = links[x];
		var type = link.getAttribute('type');
		var rel =  link.getAttribute('rel');
		if ((type && type.indexOf('css') > -1) || (rel && rel.indexOf('stylesheet') > -1)){
			link.href = link.href;
		}
	}
};