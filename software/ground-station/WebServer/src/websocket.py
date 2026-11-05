from fastapi.websockets import WebSocket, WebSocketDisconnect

# Adapted from: https://fastapi.tiangolo.com/advanced/websockets/#handling-disconnections-and-multiple-clients
class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def sendToOne(self, ws: WebSocket, data):
        try:
            await ws.send_json(data)
        except WebSocketDisconnect:
            self.disconnect(ws)

    async def sendToAll(self, data):
        for connection in self.active_connections:
            await self.sendToOne(connection, data)

def create_ws_response(msg_type: str, data: dict):
    return { "msg_type": msg_type, "data": data }