"""
This script generates some random, garbage data and sends it to the webserver to test it's API
This will later be replaced with a script that reads radio, decodes the messages and send those to the server instead
Another script using the same API could also be used for testing, fyi :3
"""

import requests
import random
import time
import requests

from data import SystemData
from webserver_api import WebServerAPI
import common

api = WebServerAPI(common.WEBSERVER_HOST, common.WEBSERVER_PORT)

if __name__ == "__main__":
    while True:
        # Generate some random data
        data = SystemData(
            altitude=int(round(5000 * random.random(), 2))
        )

        # Send the data
        try:
            response = api.update_values(data)
            response.raise_for_status()

            print(data.model_dump())
            
        except Exception as e:
            print(e)
        
        time.sleep(0.5)