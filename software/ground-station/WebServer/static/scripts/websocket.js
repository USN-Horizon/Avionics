import { UpdateField } from "./fields.js";
import { UpdateGraph } from "./charts.js";

var has_connected = false;
var connection_attempts = 0;

function set_ws_status(status, color) {
    document.getElementById('ws_status_dot').style.backgroundColor = color;
    document.getElementById('ws_status_text').textContent = status;
}

function UpdateFields(data, field_prefix="") {
    if (data == null || typeof(data) !== 'object') {
        let value = data;
        if (value == null) {
            value = "N/A";
        }
        UpdateField(field_prefix, value);
    }
    else {
        for (var prop in data) {
            if (field_prefix.length == 0) {
                UpdateFields(data[prop], prop);
            }
            else {
                UpdateFields(data[prop], field_prefix + "_" + prop);
            }
        }
    }
}

function UpdateGraphs(data, graph_prefix="") {
    if (data == null || typeof(data) !== 'object') {
        let value = data;
        if (value == null) {
            value = 0;
        }
        UpdateGraph(graph_prefix, value);
    }
    else {
        for (var prop in data) {
            if (graph_prefix.length == 0) {
                UpdateGraphs(data[prop], prop);
            }
            else {
                UpdateGraphs(data[prop], graph_prefix + "_" + prop);
            }
        }
    }
}

export function connect() {
    var websocket = new WebSocket('ws://localhost:8000/ws');
    connection_attempts++;
    
    websocket.onmessage = (event) => {
        const data = JSON.parse(event.data);

        if (!Object.hasOwn(data, "msg_type")) {
            console.log("WebSocket: Received malformed message from the webserver");
            return;
        }

        if (data.msg_type == "update_data" || data.msg_type == "all") {
            UpdateFields(data.data);
            UpdateGraphs(data.data);
            
        }
        else if (data.msg_type == "ws_msg_error") {
            console.log("WebSockets: Received an error from webserver:\n" + data.data);
        }
        else {
            console.log("WebSocket: Unknown message type received from the webserver");
        }
    }

    websocket.onopen = () => {
        console.log("WebSocket: Socket is connected");
        set_ws_status("Active", "lime");
        has_connected = true;
        connection_attempts = 0;

        // This should promt the server to send everything
        websocket.send('{"msg_type": "request_all"}');
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