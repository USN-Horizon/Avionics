import { connect } from "./websocket.js";
import { SetupTabs } from "./tab_setup.js";
import { SetupBottomBar } from "./bottom_bar_setup.js";
import { BeginConnectionDotUpdate } from "./connection_dots.js";

SetupTabs();
SetupBottomBar();

// Initial connect to the WebSocket
connect();

// Update dots every 250ms
BeginConnectionDotUpdate(250);