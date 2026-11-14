import { connect } from "./websocket.js";
import { SetupPage } from "./page_setup.js";
import { SetupTopBar } from "./top_bar_setup.js";
import { SetupTabs } from "./tab_setup.js";
import { SetupBottomBar } from "./bottom_bar_setup.js";
import { BeginConnectionDotUpdate } from "./connection_dots.js";
import { SetupCharts } from "./charts.js";

SetupPage();
SetupTopBar();
SetupTabs();
SetupBottomBar();

// Update dots every 250ms
BeginConnectionDotUpdate(250);

SetupCharts();

// Initial connect to the WebSocket
connect();