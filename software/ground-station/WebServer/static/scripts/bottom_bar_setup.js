import { SwitchToTabName } from "./tab_setup.js";

export function SetupBottomBar() {
    document.getElementById("bot-error-status-label").addEventListener("click", () => { SwitchToTabName("logs"); });
    document.getElementById("bot-warning-status-label").addEventListener("click", () => { SwitchToTabName("logs"); });
    document.getElementById("bot-msg-status-label").addEventListener("click", () => { SwitchToTabName("logs"); });
    document.getElementById("bot-websocket-status-label").addEventListener("click", () => { SwitchToTabName("network"); });
}