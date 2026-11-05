from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import RedirectResponse
from fastapi.websockets import WebSocket
from fastapi.staticfiles import StaticFiles

from pathlib import Path

import json

from src.data import SystemData
from src.common import WEBSERVER_HOST, WEBSERVER_PORT
from src.websocket import ConnectionManager, create_ws_response


ws_manager = ConnectionManager()
current_data: SystemData = SystemData()
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

# Recieves updates from the radio handler script
@app.put("/api/data")
async def update_data(request: Request, data: SystemData):
    global current_data

    # Ignore updates from other clients. Only the local machine the server is running on should be able to update these values
    if not (request.client.host == "127.0.0.1" or request.client.host == "localhost"):
        raise HTTPException(status_code=401, detail="Updating server data can only happen locally")

    # Copy received data into locally stored data, excluding values that are not given and not set
    current_data = current_data.model_copy(
        update=data.model_dump(
            exclude_unset=True,
            exclude_none=True
        )
    )

    # Send updated values to webpage via websocket connection(s)
    websocket_response = create_ws_response("update_data", data.model_dump(exclude_unset=True))
    await ws_manager.sendToAll(websocket_response)

# Create the websocket endpoint
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await ws_manager.connect(websocket)

    while True:
        try:
            # Receive data from the WebSocket
            data = await websocket.receive_text()

            # Parse the data, take apropriate actions and send a response
            try:
                data_json = json.loads(data)
                msg_type = data_json["msg_type"]
                if msg_type == "request_all":
                    response = create_ws_response("all", current_data.model_dump())
                else:
                    response = create_ws_response("ws_msg_error", { "message": f"Invalid message type \"{msg_type}\"" })
            except json.JSONDecodeError as e:
                response = create_ws_response("ws_msg_error", { "message": str(e) })

            # Send it!
            await ws_manager.sendToOne(websocket, response)
        except Exception:
            # Something malicious is brewing, close the socket
            break