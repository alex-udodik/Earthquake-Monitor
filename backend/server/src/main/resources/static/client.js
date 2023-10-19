console.log("Running code in client.js");
console.log("Hello");

var socket = new SockJS('/ws');
var stompClient = Stomp.over(socket);

var sock = new SockJS('https://www.seismicportal.eu/standing_order');

		   sock.onopen = function() {
			   console.log('Connected to Seismic Portal. Awaiting Earthquake data...');
		   };

		   sock.onmessage = function(e) {
			   var msg = JSON.parse(e.data);
			   console.log('message received : ', msg);

			   sendMessage(e.data);
		   };

		   sock.onclose = function() {
			   console.log('disconnected');
		   };


function sendMessage(data) {

	console.log('Sending data over to server via /app/chat');
    stompClient.send("/server/live", {}, data);
}