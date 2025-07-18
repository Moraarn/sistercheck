#!/bin/bash

# SisterCheck AI Integration Stop Script
# This script stops all components of the integrated system

echo "🛑 Stopping SisterCheck AI Integration System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to kill process by PID file
kill_process() {
    local pid_file=$1
    local service_name=$2
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            echo -e "${YELLOW}🛑 Stopping $service_name (PID: $pid)...${NC}"
            kill $pid
            rm "$pid_file"
            echo -e "${GREEN}✅ $service_name stopped${NC}"
        else
            echo -e "${YELLOW}⚠️  $service_name process not found, removing PID file${NC}"
            rm "$pid_file"
        fi
    else
        echo -e "${YELLOW}⚠️  No PID file found for $service_name${NC}"
    fi
}

# Stop Python AI API
echo -e "${BLUE}🤖 Stopping Python AI API...${NC}"
kill_process "sistercheck-python/python_api.pid" "Python AI API"

# Stop Node.js Backend
echo -e "${BLUE}🔧 Stopping Node.js Backend...${NC}"
kill_process "sistercheck-api/node_backend.pid" "Node.js Backend"

# Stop Flutter App
echo -e "${BLUE}📱 Stopping Flutter App...${NC}"
kill_process "codeher/flutter_app.pid" "Flutter App"

# Kill any remaining processes on the ports
echo -e "${BLUE}🧹 Cleaning up port processes...${NC}"

# Kill processes on port 5000 (Python API)
if lsof -ti:5000 > /dev/null 2>&1; then
    echo -e "${YELLOW}🛑 Killing processes on port 5000...${NC}"
    lsof -ti:5000 | xargs kill -9
fi

# Kill processes on port 3000 (Node.js Backend)
if lsof -ti:3000 > /dev/null 2>&1; then
    echo -e "${YELLOW}🛑 Killing processes on port 3000...${NC}"
    lsof -ti:3000 | xargs kill -9
fi

echo -e "${GREEN}🎉 All services stopped successfully!${NC}"
echo ""
echo -e "${BLUE}📊 System Status:${NC}"
echo -e "  🤖 Python AI API: ${RED}Stopped${NC}"
echo -e "  🔧 Node.js Backend: ${RED}Stopped${NC}"
echo -e "  📱 Flutter App: ${RED}Stopped${NC}"
echo ""
echo -e "${GREEN}✨ System shutdown complete!${NC}" 