# 🚀 Async Python Web Frameworks Comparison Suite

A comprehensive testing environment for exploring and comparing different approaches to asynchronous web development in Python. This project demonstrates real-world performance differences between Flask, FastAPI, and Quart when handling concurrent requests.

## 🎯 Why This Project Exists

Asynchronous programming in Python web development can be confusing. This project provides hands-on examples showing:

- **How different frameworks handle async operations**
- **Performance differences under concurrent load**
- **Real-world implementation patterns**
- **When to choose which framework**

## 🧪 What's Inside

#### Flask Basic
```bash
cd flask-basic
uv run gunicorn app:app --bind 0.0.0.0:8000
# Server runs on http://localhost:8000
```

#### Flask with ASGI
```bash
cd flask-asgi
uv run gunicorn -k uvicorn.workers.UvicornWorker app:asgi_app --bind 0.0.0.0:8000
# Server runs on http://localhost:8000
```

### ⚡ **FastAPI** (`fastapi/`)
**Built for Speed**

Native ASGI framework designed from the ground up for async operations with automatic API documentation and type hints.

```python
@app.get('/slow')
async def slow_endpoint():
    await asyncio.sleep(3)  # True async - other requests continue
    return {"message": "Done!", "timestamp": "..."}
```

**Key Insights:**
- Exceptional async performance
- Automatic OpenAPI/Swagger documentation
- Type safety with Pydantic
- Best for new API projects

### 🏃 **Quart** (`quart/`)
**Async Flask Clone**

Drop-in async replacement for Flask with nearly identical API but true async capabilities.

```python
# Familiar Flask syntax, true async behavior
@app.route('/slow')
async def slow_endpoint():
    await asyncio.sleep(3)  # Properly yields control
    return "Done with Quart!"
```

**Key Insights:**
- Flask developers feel at home immediately
- True async without compromises
- Perfect for migrating Flask apps to async

## 🎪 Interactive Demo

### Quick Start
```bash
# Set up everything (requires uv)
./setup.sh

# Test all frameworks simultaneously
./test_all.sh
```

### Manual Testing
Start any server:
```bash
cd fastapi && uv run uvicorn app:app --port 8000
```

Then test concurrent behavior:
```bash
# Start multiple slow requests
curl http://localhost:8000/slow &
curl http://localhost:8000/slow &
curl http://localhost:8000/slow &

# This should respond immediately (true async)
curl http://localhost:8000/
```

## 📊 Performance Insights

### Concurrency Test Results

When handling 3 simultaneous `/slow` requests (3-second delay each):

| Framework | Home Endpoint Response | True Async? | Notes |
|-----------|----------------------|-------------|--------|
| **Flask Basic** | 3+ seconds | ❌ | Blocks on slow requests |
| **Flask ASGI** | <1 second | ✅ | ASGI wrapper enables async |
| **FastAPI** | <0.1 seconds | ✅ | Exceptionally fast |
| **Quart** | <0.5 seconds | ✅ | Excellent async performance |

### When to Use Which

🏢 **Enterprise APIs**: FastAPI
- Type safety, automatic docs, excellent performance

🔄 **Migrating Flask Apps**: Quart
- Minimal code changes, familiar patterns

🛠️ **Existing Flask Codebases**: Flask ASGI
- Gradual migration, maintains compatibility

📚 **Learning/Simple Projects**: Flask Basic
- Familiar patterns, easier debugging

## 🛠️ Technical Architecture

### Environment Isolation
Each framework runs in its own virtual environment managed by `uv`:

```
test_async/
├── flask-basic/     # Minimal: just Flask
├── flask-asgi/      # Flask + asgiref + uvicorn
├── fastapi/         # FastAPI + uvicorn  
└── quart/           # Quart + uvicorn
```

### Dependencies by Framework

| Component | Flask Basic | Flask ASGI | FastAPI | Quart |
|-----------|-------------|------------|---------|-------|
| **Core** | Flask | Flask + asgiref | FastAPI | Quart |
| **Server** | Gunicorn | Gunicorn + Uvicorn | uvicorn | uvicorn |
| **Async** | Limited | Full | Native | Full |
| **Size** | ~9 packages | ~23 packages | ~20 packages | ~30 packages |

## 🧠 Learning Objectives

### Async Concepts Demonstrated
- **Event Loop Behavior**: How different frameworks yield control
- **Concurrency vs Parallelism**: Understanding the difference
- **WSGI vs ASGI**: Protocol implications for async code
- **Real-world Performance**: Measuring actual response times

### Code Patterns Explored
- Async route handlers
- Concurrent request processing  
- I/O-bound operation simulation
- Framework-specific optimizations

## 🎓 Educational Value

This project is perfect for:

- **Python developers** learning async programming
- **Web developers** choosing between frameworks
- **Students** studying concurrent programming concepts
- **Teams** evaluating framework migration strategies

## 🚀 Advanced Usage

### Custom Testing
```bash
# Test specific concurrency levels
for i in {1..10}; do curl http://localhost:8000/slow & done

# Monitor response times
time curl http://localhost:8000/
```

### Development Workflow
```bash
```bash
cd flask-basic  # or any other project
uv shell        # Activates the virtual environment
gunicorn app:app --bind 0.0.0.0:8000  # For Flask projects
# or uvicorn app:app --port 8000       # For FastAPI/Quart projects
exit           # Exit the uv shell
```
```

### Adding New Frameworks
1. Create new directory: `mkdir new-framework/`
2. Add to setup script: `setup_project "new-framework" "deps..."`
3. Update test script with new endpoints
4. Document in this README

## 🤝 Contributing

This project welcomes contributions! Ideas:
- Add more frameworks (Sanic, Tornado, etc.)
- Implement more complex async scenarios
- Add performance benchmarking tools
- Create visualization dashboards

## 📚 Further Reading

- [Python asyncio documentation](https://docs.python.org/3/library/asyncio.html)
- [ASGI vs WSGI comparison](https://asgi.readthedocs.io/)
- [FastAPI performance guide](https://fastapi.tiangolo.com/async/)
- [Quart documentation](https://quart.palletsprojects.com/)

## 👥 Authors

- Vincenzo D'Amore - [@freedev](https://github.com/freedev)
- Enrico - [@edge7](https://github.com/edge7)

---

*Built with ❤️ and `uv` for lightning-fast package management*