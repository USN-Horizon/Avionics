var has_connected = false;
var connection_attempts = 0;

function set_ws_status(status, color) {
    document.getElementById('ws_status_dot').style.backgroundColor = color;
    document.getElementById('ws_status_text').textContent = status;
}

export function connect() {
    var websocket = new WebSocket('ws://localhost:8000/ws');
    connection_attempts++;
    
    websocket.onmessage = (event) => {
        const data = JSON.parse(event.data);

        // TODO: Find a cleaner way for this!
        if (data.altitude) {
            document.getElementById('altitude').textContent = "Altitude: " + data.altitude + "m";
        }
        else {
            document.getElementById('altitude').textContent = "Altitude: N/A";
        }

        if (data.battery) {
            document.getElementById('battery').textContent = "Battery: " + data.battery + "%";
        }
        else {
            document.getElementById('battery').textContent = "Battery: N/A";
        }
    }

    websocket.onopen = () => {
        console.log("WebSocket: Socket is connected");
        set_ws_status("Active", "lime");
        has_connected = true;
        connection_attempts = 0;

        // This should promt the server to send everything
        websocket.send('{"message_type": "request_all"}');
    }

    websocket.onclose = (e) => {
        console.log("WebSocket: Socket is closed. Reconnect will be attempted in 5 seconds. ", e.reason);

        if (has_connected) {
            set_ws_status("Reconnect (" + connection_attempts + ")", "red");
        }
        else {
            set_ws_status("Connect (" + connection_attempts + ")", "red");
        }
        
        // Problem: After several connection attempts, this time increases to up to a minute! (wtf???)
        // TODO: Fix this!
        setTimeout(() => { connect(); }, 5000);
    }

    websocket.onerror = (err) => {
        console.error("WebSocket: Socket encountered error: ", err.message, "Closing socket");
        websocket.close();
    };
}