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

export function SetupPage() {
    window.addEventListener('online', () => { OnOnline(); });
    window.addEventListener('offline', () => { OnOffline(); });

    if (navigator.onLine) {
        OnOnline();
    }
    else {
        OnOffline();
    }

    document.getElementById("groundstation-icon").getElementsByClassName("status")[0].classList.add("enable");
}