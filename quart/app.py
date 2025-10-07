import asyncio
from quart import Quart, render_template
from datetime import datetime

# L'unica vera modifica è qui: si usa Quart invece di Flask
app = Quart(__name__)

@app.route('/slow')
async def slow_endpoint():
    """
    Questo endpoint ora si comporterà in modo veramente asincrono.
    Mentre l'await è in pausa, il server è libero di gestire altre richieste.
    """
    start = datetime.now()
    print(f"[{start.strftime('%H:%M:%S')}] Richiesta a /slow (Quart) iniziata")
    
    # Questa pausa ora cede il controllo all'event loop di Uvicorn
    await asyncio.sleep(3)
    
    end = datetime.now()
    print(f"[{end.strftime('%H:%M:%S')}] Richiesta a /slow (Quart) terminata")
    
    return f"Fatto con Quart! Iniziato alle {start.strftime('%H:%M:%S')}\n"

@app.route('/')
async def home():
    """
    Questo endpoint risponderà istantaneamente, anche se una richiesta a /slow è in corso.
    """
    return "Server Quart (Async Flask) è in esecuzione. Prova /slow\n"