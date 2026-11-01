import time
import csv

from src.data import SystemData
from src.webserver_api import WebServerAPI
from src.common import WEBSERVER_HOST, WEBSERVER_PORT

api = WebServerAPI(WEBSERVER_HOST, WEBSERVER_PORT)

initial_time = -10
start_time = time.time()

data_points = []

if __name__ == "__main__":
    # Load simulated flight data from csv file (thanks Systems!)
    with open("flight.csv", "r") as csvfile:
        data_points = list(csv.DictReader(csvfile, delimiter=','))
    
    end_time = float(data_points[-1]["time"])

    print(start_time)
    print(end_time)
    index = 0

    while True:
        current_time = time.time() - start_time + initial_time

        while True:
            if current_time >= end_time:
                index = len(data_points) - 1
            if current_time < end_time and current_time > float(data_points[index]["time"]):
                index = index + 1
            else:
                break

        # Read the data
        dp = data_points[index]

        # "Package" the data
        data = SystemData(
            position={
                "x":dp["pos_x"],
                "y":dp["pos_y"],
                "z":dp["pos_z"]
            },
            velocity={
                "x":dp["vel_x"],
                "y":dp["vel_y"],
                "z":dp["vel_z"]
            },
            acceleration={
                "x":dp["acc_x"],
                "y":dp["acc_y"],
                "z":dp["acc_z"]
            },
        
            attitude={
                "i":dp["att_e1"],
                "j":dp["att_e2"],
                "k":dp["att_e3"],
                "w":dp["att_e4"]
            },
            angular_velocity={
                "x":dp["angvel_x"],
                "y":dp["angvel_y"],
                "z":dp["angvel_z"]
            },
            angular_acceleration={
                "x":dp["angacc_x"],
                "y":dp["angacc_y"],
                "z":dp["angacc_z"]
            },

            altitude=dp["alt"],
            state=dp["state"],
        
            gnss={
                "lon":dp["gnss_lon"],
                "lat":dp["gnss_lat"],
                "alt":dp["gnss_alt"]
            },
            battery=dp["bat"],
            temperature=dp["temp"],
            pressure=dp["pres"]
        )

        # Send the data
        try:
            response = api.update_values(data)
            response.raise_for_status()
            
        except Exception as e:
            print(e)