var has_connected = false;
var connection_attempts = 0;

function set_ws_status(status, color) {
    document.getElementById('ws_status_dot').style.backgroundColor = color;
    document.getElementById('ws_status_text').textContent = status;
}

function connect() {
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

        console.log("Socket recieved: ", data);
    }

    websocket.onopen = () => {
        console.log("Socket is connected");
        set_ws_status("Active", "lime");
        has_connected = true;
        connection_attempts = 0;
    }

    websocket.onclose = (e) => {
        console.log("Socket is closed. Reconnect will be attempted in 1 second. ", e.reason);

        if (has_connected) {
            set_ws_status("Reconnect (" + connection_attempts + ")", "red");
        }
        else {
            set_ws_status("Connect (" + connection_attempts + ")", "red");
        }
        
        setTimeout(() => { connect(); }, 1000);
    }

    websocket.onerror = (err) => {
        console.error('Socket encountered error: ', err.message, 'Closing socket');
        websocket.close();
    };
}

const tabs = document.querySelectorAll(".tab");
const contents = document.querySelectorAll(".tab-content");

tabs.forEach(tab => {
    tab.addEventListener("click", () => {
        // Remove active from all tabs and content tabs
        tabs.forEach(t => t.classList.remove("active"));
        contents.forEach(c => c.classList.remove("active"));

        // Activate this tab
        tab.classList.add("active");

        const target = document.getElementById(tab.dataset.tab);

        // Activate this content tab
        target.classList.add("active");
    });
});

var dot_state = 0;
var dot_pan_dir = 1;

function UpdateConnectionDots() {
    // Get all connection dots in the document
    connection_dots_list = document.querySelectorAll(".connection-dots");

    connection_dots_list.forEach(connection_dots => {
        dots = connection_dots.querySelectorAll(".connection-dot");

        // Disable all dots
        dots.forEach(dot => {
            dot.classList.remove("active");
            dot.classList.remove("enable");
        });

        // If disabled, no need to do more
        if (!connection_dots.classList.contains("enable")) return;

        // Activate all dots, and enable the one which corresponds to the enabled one
        dots.forEach(dot => {
            dot.classList.add("active");
            if (dot.dataset.pos == dot_state) dot.classList.add("enable");
        });
    });

    // Update the dot state (kind of messy but it works)
    dot_state = dot_state + dot_pan_dir;
    if (dot_state < 0) {
        dot_pan_dir *= -1;
    }
    if (dot_state > 2) {
        dot_pan_dir *= -1;
    }
}

// Initial connect to the WebSocket
connect();

// Update dots every 250ms
setInterval(UpdateConnectionDots, 250);