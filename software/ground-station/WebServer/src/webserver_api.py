import requests

from src.data import SystemData

class WebServerAPI:
    def __init__(self, host: str, port: str):
        self.host = host
        self.port = port

    def _send_JSON(self, data: SystemData, exclude_unset=False) -> requests.Response:
        response = requests.put(
            "http://" + self.host + ":" + self.port + "/api/data",
            json=data.model_dump(exclude_unset=exclude_unset),
            timeout=5
        )

        return response
    
    def update_values(self, data: SystemData) -> requests.Response:
        return self._send_JSON(data, True)
        
    def set_server_data(self, data: SystemData) -> requests.Response:
        return self._send_JSON(data)

    def get_values(self, fields: list[str]) -> requests.Response:
        response = requests.post(
            "http://" + self.host + ":" + self.port + "/api/data",
            json={
                "fields": fields
            },
            timeout=5
        )

        return response        