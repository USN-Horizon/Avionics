from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.websockets import WebSocket, WebSocketDisconnect, WebSocketState
from fastapi.staticfiles import StaticFiles
from pathlib import Path

from data import SystemData

current_data: SystemData = SystemData()
connections: list[WebSocket] = []

# This is a VERY janky solution
# TODO: Fix this lol
def RemoveDisconnectedWebSockets():
    global connections
    connections = [ c for c in connections if c.client_state != WebSocketState.DISCONNECTED ]

app = FastAPI()

# Tell FastAPI to serve files in the static folder
# Files will be found on for example http://localhost:8000/static/index.html
BASE_DIR = Path(__file__).resolve().parent
STATIC_DIR = BASE_DIR / "static"
app.mount(
    "/static",
    StaticFiles(directory=STATIC_DIR),
    name="static",
)

# Define the route to the main page, everything else SHOULD be handled by the mounting to static
@app.get("/")
async def home():
    return FileResponse(STATIC_DIR / "index.html")

# Recieves updates (put) to values on the server
# TODO: This should only really happen from the same machine (so no one can send false data, on purpose or not)
# Find a way to detect this and ignore
@app.put("/api/update")
async def update_data(data: SystemData):
    global connections

    if data.altitude:
        current_data.altitude = data.altitude
    if data.battery:
        current_data.battery = data.battery

    # Send updated values to webpage via websocket connection(s)
    connection_closed = False
    for connection in connections:
        try:
            await connection.send_json(current_data.model_dump(exclude_unset=True))
        except WebSocketDisconnect:
            connection_closed = True

    # Remove any connections that may have been closed (janky)
    if connection_closed:
        RemoveDisconnectedWebSockets()

# Create the websocket endpoint
# This has a habit of throwing some exceptions (but not crashing!) when relaunching a page
# TODO: WebSocket connection manager perhaps?
# https://fastapi.tiangolo.com/advanced/websockets/#handling-disconnections-and-multiple-clients
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    connections.append(websocket)

    while True:
        try:
            # I have no idea why, but this seems to keep the websocket alive lol
            data = await websocket.receive_text()
            await websocket.send_text(data)
        except WebSocketDisconnect:
            RemoveDisconnectedWebSockets()