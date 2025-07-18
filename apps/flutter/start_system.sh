#!/bin/bash

# SisterCheck AI Integration Startup Script
# This script starts all components of the integrated system

echo "🚀 Starting SisterCheck AI Integration System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a port is in use
port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

if ! command_exists python3; then
    echo -e "${RED}❌ Python 3 is not installed. Please install Python 3.8 or higher.${NC}"
    exit 1
fi

if ! command_exists node; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 16 or higher.${NC}"
    exit 1
fi

if ! command_exists flutter; then
    echo -e "${YELLOW}⚠️  Flutter is not installed. Flutter app will not be started.${NC}"
fi

echo -e "${GREEN}✅ Prerequisites check completed${NC}"

# Start Python AI API
echo -e "${BLUE}🤖 Starting Python AI API...${NC}"

if port_in_use 5000; then
    echo -e "${YELLOW}⚠️  Port 5000 is already in use. Skipping Python API startup.${NC}"
else
    cd sistercheck-python
    
    # Check if virtual environment exists
    if [ ! -d "venv" ]; then
        echo -e "${YELLOW}📦 Creating Python virtual environment...${NC}"
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install dependencies
    echo -e "${YELLOW}📦 Installing Python dependencies...${NC}"
    pip install -r requirements.txt
    
    # Train model if not already trained
    if [ ! -f "trained_model.pkl" ]; then
        echo -e "${YELLOW}🧠 Training AI model...${NC}"
        python train_model.py
    fi
    
    # Start Flask API in background
    echo -e "${GREEN}🚀 Starting Python AI API on port 5000...${NC}"
    python app.py &
    PYTHON_PID=$!
    echo $PYTHON_PID > python_api.pid
    
    cd ..
    
    # Wait for Python API to start
    echo -e "${YELLOW}⏳ Waiting for Python API to start...${NC}"
    sleep 5
    
    # Test Python API
    if curl -s http://localhost:5000/health > /dev/null; then
        echo -e "${GREEN}✅ Python AI API is running on http://localhost:5000${NC}"
    else
        echo -e "${RED}❌ Python AI API failed to start${NC}"
        exit 1
    fi
fi

# Start Node.js Backend
echo -e "${BLUE}🔧 Starting Node.js Backend...${NC}"

if port_in_use 3000; then
    echo -e "${YELLOW}⚠️  Port 3000 is already in use. Skipping Node.js backend startup.${NC}"
else
    cd sistercheck-api
    
    # Install dependencies
    echo -e "${YELLOW}📦 Installing Node.js dependencies...${NC}"
    npm install
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}📝 Creating .env file...${NC}"
        cat > .env << EOF
PORT=3000
PYTHON_API_URL=http://localhost:5000
MONGODB_URI=mongodb://localhost:27017/sistercheck
JWT_SECRET=your-secret-key-here
EOF
        echo -e "${YELLOW}⚠️  Please update the .env file with your actual configuration${NC}"
    fi
    
    # Start Node.js server in background
    echo -e "${GREEN}🚀 Starting Node.js Backend on port 3000...${NC}"
    npm run dev &
    NODE_PID=$!
    echo $NODE_PID > node_backend.pid
    
    cd ..
    
    # Wait for Node.js backend to start
    echo -e "${YELLOW}⏳ Waiting for Node.js backend to start...${NC}"
    sleep 5
    
    # Test Node.js backend
    if curl -s http://localhost:3000/ > /dev/null; then
        echo -e "${GREEN}✅ Node.js Backend is running on http://localhost:3000${NC}"
    else
        echo -e "${RED}❌ Node.js Backend failed to start${NC}"
        exit 1
    fi
fi

# Start Flutter App (if Flutter is available)
if command_exists flutter; then
    echo -e "${BLUE}📱 Starting Flutter App...${NC}"
    
    cd codeher
    
    # Get dependencies
    echo -e "${YELLOW}📦 Getting Flutter dependencies...${NC}"
    flutter pub get
    
    # Check if device is connected
    if flutter devices | grep -q "connected"; then
        echo -e "${GREEN}🚀 Starting Flutter app...${NC}"
        flutter run &
        FLUTTER_PID=$!
        echo $FLUTTER_PID > flutter_app.pid
        echo -e "${GREEN}✅ Flutter app is starting...${NC}"
    else
        echo -e "${YELLOW}⚠️  No Flutter device connected. Run 'flutter devices' to see available devices.${NC}"
    fi
    
    cd ..
else
    echo -e "${YELLOW}⚠️  Flutter not found. Skipping Flutter app startup.${NC}"
fi

echo -e "${GREEN}🎉 SisterCheck AI Integration System is starting up!${NC}"
echo ""
echo -e "${BLUE}📊 System Status:${NC}"
echo -e "  🤖 Python AI API: ${GREEN}http://localhost:5000${NC}"
echo -e "  🔧 Node.js Backend: ${GREEN}http://localhost:3000${NC}"
echo -e "  📱 Flutter App: ${GREEN}Check your device${NC}"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo -e "  • Use 'flutter devices' to see available devices"
echo -e "  • Check logs in each directory for detailed information"
echo -e "  • Run './stop_system.sh' to stop all services"
echo ""
echo -e "${BLUE}🔗 API Documentation:${NC}"
echo -e "  • Python AI API: http://localhost:5000/health"
echo -e "  • Node.js Backend: http://localhost:3000/"
echo ""
echo -e "${GREEN}✨ Happy coding!${NC}" 