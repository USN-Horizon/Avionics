from pydantic import BaseModel

class Vector3(BaseModel):
    x: float | None = None
    y: float | None = None
    z: float | None = None

class Quaternion(BaseModel):
    i: float | None = None
    j: float | None = None
    k: float | None = None
    w: float | None = None

class GNSS(BaseModel):
    longitude: float | None = None
    latitude: float | None = None
    altitude: float| None = None

class SystemData(BaseModel):
    position: Vector3 = Vector3()
    velocity: Vector3 = Vector3()
    acceleration: Vector3 = Vector3()

    attitude: Quaternion = Quaternion()
    angular_velocity: Vector3 = Vector3()
    angular_acceleration: Vector3 = Vector3()
    
    altitude: float | None = None
    state: str | None = None

    gnss: GNSS = GNSS()
    battery: float | None = None
    temperature: float | None = None
    pressure: float | None = None