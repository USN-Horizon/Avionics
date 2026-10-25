import { connect } from "./websocket.js";
import { SetupTabs } from "./tab_setup.js";
import { BeginConnectionDotUpdate } from "./connection_dots.js";

SetupTabs();

// Initial connect to the WebSocket
connect();

// Update dots every 250ms
BeginConnectionDotUpdate(250);