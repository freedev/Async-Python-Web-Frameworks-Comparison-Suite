#!/bin/bash

# ==============================================================================
# Enhanced test script for all async Python applications
# ==============================================================================

set -e  # Exit on any error

# Global port to use for testing (can be changed if needed)
TEST_PORT=8000

# Cleanup function to kill any process on the test port
cleanup() {
    echo "--- Cleaning up: looking for processes on port $TEST_PORT ---"
    PID_TO_KILL=$(lsof -t -i:$TEST_PORT 2>/dev/null || true)
    
    if [ -n "$PID_TO_KILL" ]; then
        echo "Found processes on port $TEST_PORT with PID(s): $PID_TO_KILL. Terminating..."
        kill -9 $PID_TO_KILL 2>/dev/null || true
        sleep 1
        echo "Processes terminated."
    else
        echo "No processes found on port $TEST_PORT."
    fi
    echo "----------------------------------------------------"
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Function to wait for server to be ready
wait_for_server() {
    echo -n "Waiting for server to be ready..."
    for i in {1..15}; do
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:$TEST_PORT/ | grep -q "200"; then
            echo " OK!"
            return 0
        fi
        echo -n "."
        sleep 1
    done
    echo " FAILED! Server didn't respond in time."
    return 1
}

# Function to test concurrent requests
test_concurrent_requests() {
    local app_name=$1
    echo "🔄 Testing concurrent requests for $app_name..."
    
    # Start 3 slow requests in parallel
    echo "Starting 3 concurrent slow requests..."
    curl -s "http://localhost:$TEST_PORT/slow" > /tmp/test1.log &
    PID1=$!
    sleep 0.5
    curl -s "http://localhost:$TEST_PORT/slow" > /tmp/test2.log &
    PID2=$!
    sleep 0.5
    curl -s "http://localhost:$TEST_PORT/slow" > /tmp/test3.log &
    PID3=$!
    
    # Test if the home endpoint is still responsive
    echo "Testing if home endpoint responds while slow requests are running..."
    for i in {1..5}; do
        response=$(curl -s -w "%{time_total}" "http://localhost:$TEST_PORT/" 2>/dev/null | tail -1)
        if (( $(echo "$response < 1.0" | bc -l 2>/dev/null || echo 0) )); then
            echo "✅ Home endpoint responded quickly ($response seconds)"
        else
            echo "⚠️  Home endpoint was slow ($response seconds)"
        fi
        sleep 1
    done
    
    # Wait for all slow requests to complete
    wait $PID1 $PID2 $PID3
    echo "✅ All concurrent requests completed"
    echo
}

# Function to test a single application
test_application() {
    local app_dir=$1
    local app_name=$2
    local start_command=$3
    
    echo "🧪 Testing $app_name ($app_dir)"
    echo "==============================================="
    
    # Navigate to app directory
    cd "$app_dir"
    
    # Check if uv project is properly set up
    if [ ! -f "pyproject.toml" ]; then
        echo "❌ pyproject.toml not found in $app_dir. Run setup.sh first!"
        cd ..
        return 1
    fi
    
    # Start the application in background using uv run
    echo "Starting $app_name server..."
    uv run $start_command &
    SERVER_PID=$!
    
    # Wait for server to be ready
    if wait_for_server; then
        # Test basic functionality
        echo "📡 Testing basic endpoint..."
        home_response=$(curl -s "http://localhost:$TEST_PORT/")
        echo "Home response: $home_response"
        
        # Test concurrent behavior
        test_concurrent_requests "$app_name"
        
        echo "✅ $app_name tests completed successfully!"
    else
        echo "❌ $app_name server failed to start properly"
    fi
    
    # Cleanup this server
    cleanup
    
    # Return to main directory
    cd ..
    echo
}

# Main testing sequence
echo "🚀 Starting comprehensive async Python application tests..."
echo

# Clean up any existing processes
cleanup

# Test each application
test_application "flask-basic" "Flask Basic" "gunicorn -w 1 app:app --bind 0.0.0.0:$TEST_PORT --log-level error"
test_application "flask-asgi" "Flask with ASGI (Gunicorn with Uvicorn workers)" "gunicorn -w 1 -k uvicorn.workers.UvicornWorker app:asgi_app --bind 0.0.0.0:$TEST_PORT --log-level error"
test_application "flask-asgi" "Flask with ASGI (Uvicorn)" "uvicorn app:asgi_app --host 0.0.0.0 --port $TEST_PORT --log-level error"
test_application "fastapi" "FastAPI" "uvicorn app:app --host 0.0.0.0 --port $TEST_PORT --log-level error"
test_application "quart" "Quart" "uvicorn app:app --host 0.0.0.0 --port $TEST_PORT --log-level error"

echo "🎉 All tests completed!"
echo
echo "📊 Summary:"
echo "- Flask Basic: Traditional Flask with Gunicorn (limited async behavior)"
echo "- Flask ASGI (Gunicorn): Flask with ASGI wrapper using Gunicorn + Uvicorn workers"
echo "- Flask ASGI (Uvicorn): Flask with ASGI wrapper using standalone Uvicorn"
echo "- FastAPI: Native async web framework with excellent performance"
echo "- Quart: Async Flask alternative with similar API"
echo
echo "💡 For production, FastAPI or Quart are recommended for true async behavior."
echo "💡 Flask ASGI with Uvicorn standalone typically performs better than Gunicorn + Uvicorn workers."