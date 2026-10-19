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

    console.log(data);
}

websocket.addEventListener('open', (event) => {
    document.getElementById('ws_status').textContent = "WebSocket status: Active";
});

websocket.addEventListener('close', (event) => {
    document.getElementById('ws_status').textContent = "WebSocket status: Disconnected";
});