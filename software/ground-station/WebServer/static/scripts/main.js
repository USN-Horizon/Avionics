var has_connected = false;

function set_ws_status(status) {
    document.getElementById('ws_status').textContent = "WebSocket status: " + status;
}

function connect() {
    var websocket = new WebSocket('ws://localhost:8000/ws');

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

        console.log("Socket recieved: ", data);
    }

    websocket.onopen = () => {
        console.log("Socket is connected");
        set_ws_status("Active");
        has_connected = true;
    }

    websocket.onclose = (e) => {
        console.log("Socket is closed. Reconnect will be attempted in 1 second. ", e.reason);

        if (has_connected) {
            set_ws_status("Reconnecting...");
        }
        else {
            set_ws_status("Connecting...");
        }
        
        setTimeout(() => { connect(); }, 1000);
    }

    websocket.onerror = (err) => {
        console.error('Socket encountered error: ', err.message, 'Closing socket');
        websocket.close();
    };
}

connect();