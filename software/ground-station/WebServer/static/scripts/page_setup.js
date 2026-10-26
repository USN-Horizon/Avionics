import { UpdateField } from "./fields.js";

export function SetupPage() {
    window.addEventListener('online', () => {
        document.getElementById("wifi-connection").classList.add("enable");
        UpdateField("network-status", "Online");
    });

    window.addEventListener('offline', () => {
        document.getElementById("wifi-connection").classList.remove("enable");
        UpdateField("network-status", "Offline");
    });

    if (navigator.onLine) {
        document.getElementById("wifi-connection").classList.add("enable");
        UpdateField("network-status", "Online");
    }
}