from pydantic import BaseModel

class SystemData(BaseModel):
    """
    Any data that could be sent from the rocket to the server
    Will naturally be expanded on later
    """
    
    altitude: int | None = None
    battery: float | None = None