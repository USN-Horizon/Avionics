import { SwitchToTabName } from "./tab_setup.js";

export function SetupTopBar() {
    document.getElementById("payload-icon").addEventListener("click", () => { SwitchToTabName("payload"); });
    document.getElementById("avionics-icon").addEventListener("click", () => { SwitchToTabName("avionics"); });
    document.getElementById("groundstation-icon").addEventListener("click", () => { SwitchToTabName("dashboard"); });
    document.getElementById("wifi-icon").addEventListener("click", () => { SwitchToTabName("network"); });
}