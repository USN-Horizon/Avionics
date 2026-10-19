# Web Server

TODO: More documentation

## Installation and Setup

1. Create a python virtual environment in project root
```bash
python -m venv venv
```
2. Activate the environment
```bash
# Linux
source path/to/venv/bin/activate

# Windows
path\to\venv\Scripts\activate
```

3. Install all dependencies from [requirements.txt](./requirements.txt)
```bash
pip install <dependencies-here>
```

## Usage

### Running the Webserver

Currently, the webserver only runs on localhost. But after configuring the Raspberry Pi it should allow anyone on its local network to connect to it.

To run the server, run this command:
```bash
uvicorn server:app
```
The flag *--reload* may be used to automatically restart the server when changes have been made to the script.

The webpage should then be available at: http://localhost:8000/

### Generating data

The server has an API that allows for updating of its stored values. Run the script *data_gen.py* to start sending some messages to the server. In the future, this script will also take care of radio communication and decoding.

The URL endpoint for put requests is http://localhost:8000/api/update

### Docs

The FastAPI library also has a built in overview and interactive documentation. When the server is running, go to http://localhost:8000/docs