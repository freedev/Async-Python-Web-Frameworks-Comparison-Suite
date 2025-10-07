#!/bin/bash

# ==============================================================================
# Setup script for creating isolated virtual environments for each Python app using uv
# ==============================================================================

set -e  # Exit on any error

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "❌ uv is not installed. Please install it first:"
    echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "   or visit: https://docs.astral.sh/uv/getting-started/installation/"
    exit 1
fi

echo "🚀 Setting up virtual environments for async Python applications using uv..."
echo

# Function to setup a single project
setup_project() {
    local project_dir=$1
    local project_name=$2
    local deps=("${@:3}")  # All arguments after the second one are dependencies
    
    echo "📦 Setting up $project_dir..."
    
    cd "$project_dir"
    
    # Initialize uv project with a unique name
    echo "  Initializing uv project..."
    uv init --name "$project_name" --no-readme > /dev/null 2>&1 || true
    
    # Install dependencies
    if [ ${#deps[@]} -gt 0 ]; then
        echo "  Installing dependencies: ${deps[*]}"
        uv add "${deps[@]}"
    fi
    
    echo "  ✅ $project_dir setup complete!"
    echo
    
    cd ..
}

# Setup each project with its specific dependencies
setup_project "flask-basic" "flask-basic-test" "flask[async]>=2.3.0" "gunicorn>=21.0.0"
setup_project "flask-asgi" "flask-asgi-test" "flask[async]>=2.3.0" "asgiref>=3.6.0" "uvicorn[standard]>=0.20.0" "gunicorn>=21.0.0"
setup_project "fastapi" "fastapi-test" "fastapi>=0.100.0" "uvicorn[standard]>=0.20.0"
setup_project "quart" "quart-test" "quart>=0.18.0" "uvicorn[standard]>=0.20.0"

echo "🎉 All environments set up successfully!"
echo
echo "📋 Usage instructions:"
echo "To work with a specific project:"
echo "  cd flask-basic && uv shell    # For Flask basic"
echo "  cd flask-asgi && uv shell     # For Flask with ASGI"
echo "  cd fastapi && uv shell        # For FastAPI"
echo "  cd quart && uv shell          # For Quart"
echo
echo "To run the applications:"
echo "  Flask basic:  cd flask-basic && uv run gunicorn app:app --bind 0.0.0.0:8000"
echo "  Flask ASGI:   cd flask-asgi && uv run gunicorn -k uvicorn.workers.UvicornWorker app:asgi_app --bind 0.0.0.0:8000"
echo "  FastAPI:      cd fastapi && uv run uvicorn app:app --host 0.0.0.0 --port 8000"
echo "  Quart:        cd quart && uv run uvicorn app:app --host 0.0.0.0 --port 8000"
echo
echo "Or use 'uv shell' to activate the environment, then run commands normally."
echo "Use 'exit' to leave the uv shell."