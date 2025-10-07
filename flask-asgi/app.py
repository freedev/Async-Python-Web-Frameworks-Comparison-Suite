import asyncio
from flask import Flask
from datetime import datetime
from asgiref.wsgi import WsgiToAsgi

app = Flask(__name__)

@app.route('/slow')
async def slow_endpoint():
    start = datetime.now()
    print(f"[{start.strftime('%H:%M:%S')}] Request started")
    
    # Simula operazione I/O asincrona (es. chiamata API, query DB)
    await asyncio.sleep(3)
    
    end = datetime.now()
    print(f"[{end.strftime('%H:%M:%S')}] Request finished")
    
    return f"Done! Started at {start.strftime('%H:%M:%S')}\n"

@app.route('/')
async def home():
    return "Server is running. Try /slow\n"

# Wrapper ASGI necessario per Uvicorn
asgi_app = WsgiToAsgi(app)

# This app is designed to run with Gunicorn using Uvicorn workers:
# gunicorn -k uvicorn.workers.UvicornWorker app:asgi_app --bind 0.0.0.0:8000