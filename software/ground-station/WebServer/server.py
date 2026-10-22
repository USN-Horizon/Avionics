from fastapi import FastAPI, HTTPException
from fastapi.responses import RedirectResponse
from fastapi.websockets import WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles

from pathlib import Path
from pydantic import BaseModel

from src.common import WEBSERVER_HOST, WEBSERVER_PORT
from src.data import SystemData

current_data: SystemData = SystemData()

# Adapted from: https://fastapi.tiangolo.com/advanced/websockets/#handling-disconnections-and-multiple-clients
class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def sendToAll(self, data):
        for connection in self.active_connections:
            try:
                await connection.send_json(data)
            except WebSocketDisconnect:
                self.disconnect(connection)

ws_manager = ConnectionManager()

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
    # Redirect to the index.html file
    url = "http://" + WEBSERVER_HOST + ":" + WEBSERVER_PORT + "/static/index.html"
    return RedirectResponse(url=url)

# Recieves updates (put) to values on the server
# TODO: This should only really happen from the same machine (so no one can send false data, on purpose or not)
# Find a way to detect this and ignore
@app.put("/api/data")
async def update_data(data: SystemData):
    global connections

    if data.altitude:
        current_data.altitude = data.altitude
    if data.battery:
        current_data.battery = data.battery

    # Send updated values to webpage via websocket connection(s)
    await ws_manager.sendToAll(current_data.model_dump(exclude_unset=True))

class QueryRequest(BaseModel):
    fields: list[str]

# Use POST .../api/data with a body specifying which elements you want to retrieve
@app.post("/api/data")
async def update_data(request: QueryRequest):
    result = {}
    unknown_fields = []

    data_fields = current_data.model_dump()

    for field in request.fields:
        if field in data_fields:
            result[field] = data_fields[field]
        else:
            unknown_fields.append(field)

    if len(unknown_fields) > 0:
        raise HTTPException(
            status_code=404,
            detail=f"Unknown field(s): {unknown_fields}"
        )

    return result

# Create the websocket endpoint
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await ws_manager.connect(websocket)

    while True:
        try:
            data = await websocket.receive_text()
            await websocket.send_text(data)
        except Exception:
            break