import asyncio
from fastapi import FastAPI
from datetime import datetime

# In FastAPI, l'oggetto 'app' è l'equivalente dell'app Flask
app = FastAPI()

@app.get('/slow')
async def slow_endpoint():
    """
    Questo endpoint simula un'operazione I/O-bound asincrona.
    Con FastAPI e Uvicorn, il server può gestire altre richieste
    mentre attende il completamento di asyncio.sleep().
    """
    start = datetime.now()
    print(f"[{start.strftime('%H:%M:%S')}] Richiesta a /slow iniziata")
    
    # Simula un'operazione di I/O asincrona (es. chiamata API, query al database)
    await asyncio.sleep(3)
    
    end = datetime.now()
    print(f"[{end.strftime('%H:%M:%S')}] Richiesta a /slow terminata")
    
    return {
        "message": "Done!",
        "start_time": start.strftime('%H:%M:%S'),
        "end_time": end.strftime('%H:%M:%S')
    }

@app.get('/')
async def home():
    """
    Endpoint principale per verificare che il server sia in esecuzione.
    """
    return {"message": "Server asincrono è in esecuzione. Prova /slow"}

# Non c'è bisogno di un blocco 'if __name__ == "__main__":' per Uvicorn.
# Il server viene avviato da riga di comando.