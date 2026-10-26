import { connect } from "./websocket.js";
import { SetupPage } from "./page_setup.js";
import { SetupTabs } from "./tab_setup.js";
import { SetupBottomBar } from "./bottom_bar_setup.js";
import { BeginConnectionDotUpdate } from "./connection_dots.js";

SetupPage();
SetupTabs();
SetupBottomBar();

// Initial connect to the WebSocket
connect();

// Update dots every 250ms
BeginConnectionDotUpdate(250);