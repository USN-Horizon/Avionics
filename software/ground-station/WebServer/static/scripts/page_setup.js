import { UpdateField } from "./fields.js";

function OnOnline() {
    const connection_dots = document.getElementById("wifi-connection");
    connection_dots.classList.add("enable");
    connection_dots.title = "Internet Connection Status: OK";

    document.getElementById("wifi-icon").getElementsByClassName("status")[0].classList.add("enable");
    
    UpdateField("network-status", "Online");
}

function OnOffline() {
    const connection_dots = document.getElementById("wifi-connection");
    connection_dots.classList.remove("enable");
    connection_dots.title = "Internet Connection Status: Not Present";

    document.getElementById("wifi-icon").getElementsByClassName("status")[0].classList.remove("enable");

    UpdateField("network-status", "Offline");
}

function BeforeUnload(event) {
    // Would be nice to set our own message inside the pop-up, but this is disabled on modern browsers for security reasons :(
    event.preventDefault(); // This makes the pop-up show up
    event.returnValue = ""; // This is just vibing for compatibility reasons
}

export function SetupPage() {
    window.addEventListener('beforeunload', BeforeUnload);
    window.addEventListener('online', OnOnline);
    window.addEventListener('offline', OnOffline);

    if (navigator.onLine) {
        OnOnline();
    }
    else {
        OnOffline();
    }

    document.getElementById("groundstation-icon").getElementsByClassName("status")[0].classList.add("enable");
}