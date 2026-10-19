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

if __name__ == "__main__":
    while True:
        # Generate some random data
        data = SystemData(
            altitude=int(round(5000 * random.random(), 2))
        )

        # Send the data
        try:
            response = requests.put(
                "http://127.0.0.1:8000/api/update",
                json=data.model_dump(),
                timeout=5
            )

            print(data.model_dump())

            response.raise_for_status()
        except Exception as e:
            print(e)
        
        time.sleep(0.5)