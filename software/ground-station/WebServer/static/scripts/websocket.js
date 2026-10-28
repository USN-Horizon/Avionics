import { UpdateField } from "./fields.js";

var has_connected = false;
var connection_attempts = 0;

function set_ws_status(status, color) {
    document.getElementById('ws_status_dot').style.backgroundColor = color;
    document.getElementById('ws_status_text').textContent = status;
}

function UpdateFields(data, field_prefix) {
    if (data == null || typeof(data) !== 'object') {
        let value = data;
        if (value == null) {
            value = "N/A";
        }
        UpdateField(field_prefix, value);
    }
    else {
        for (var prop in data) {
            UpdateFields(data[prop], field_prefix + "_" + prop);
        }
    }
}

export function connect() {
    var websocket = new WebSocket('ws://localhost:8000/ws');
    connection_attempts++;
    
    websocket.onmessage = (event) => {
        const data = JSON.parse(event.data);
        UpdateFields(data, "field");
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