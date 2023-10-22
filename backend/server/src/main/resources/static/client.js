
/*var socket = new SockJS('/ws');
var stompClient = Stomp.over(socket);

var sock = new SockJS('https://www.seismicportal.eu/standing_order');

		   sock.onopen = function() {

		       console.log("Running code in client.js");
               sendMessage('Running code in client.js', '/server/clientLogs');
			   console.log('Connected to Seismic Portal Websocket. Awaiting Earthquake data...');
			   sendMessage('Connected to Seismic Portal Websocket. Awaiting Earthquake data...', '/server/clientLogs');


		   };

		   sock.onmessage = function(e) {
			   var msg = JSON.parse(e.data);
			   console.log('message received : ', msg);
			   sendMessage(e.data, "/server/live");
			   sendMessage("Earthquake event", "/server/clientLogs");
		   };

		   sock.onclose = function() {
			   console.log('Disconnected from Seismic Portal Websocket.');
			   sendMessage('Disconnected from Seismic Portal Websocket.', '/server/clientLogs');
		   };



function sendMessage(data, endpoint) {

	console.log('Sending data over to server via ' + endpoint);
    stompClient.send(endpoint, {}, data);
}
*/