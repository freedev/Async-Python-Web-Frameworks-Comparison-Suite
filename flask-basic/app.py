import asyncio
from flask import Flask
from datetime import datetime

app = Flask(__name__)

@app.route('/slow')
async def slow_endpoint():
    start = datetime.now()
    print(f"[{start.strftime('%H:%M:%S')}] Request started")
    
    # Simula operazione I/O asincrona (es. chiamata API, query DB)
    tasks = [
           asyncio.sleep(3),asyncio.sleep(3),asyncio.sleep(3),asyncio.sleep(3),asyncio.sleep(3),asyncio.sleep(3)
       ]
    results = await asyncio.gather(*tasks)
    
    end = datetime.now()
    print(f"[{end.strftime('%H:%M:%S')}] Request finished")
    
    return f"Done! Started at {start.strftime('%H:%M:%S')}\n"

@app.route('/')
async def home():
    return "Server is running. Try /slow\n"

# This app is designed to run with Gunicorn:
# gunicorn app:app --bind 0.0.0.0:8000