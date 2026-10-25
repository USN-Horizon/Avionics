var dot_state = 0;
var dot_pan_dir = 1;

function UpdateConnectionDots() {
    // Get all connection dots in the document
    var connection_dots_list = document.querySelectorAll(".connection-dots");

    connection_dots_list.forEach(connection_dots => {
        var dots = connection_dots.querySelectorAll(".connection-dot");

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

export function BeginConnectionDotUpdate(interval_ms) {
    setInterval(UpdateConnectionDots, interval_ms);
}