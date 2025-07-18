#!/bin/bash

# SisterCheck Docker Management Script
# Usage: ./docker-scripts.sh [command]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose > /dev/null 2>&1; then
        print_error "Docker Compose is not installed. Please install Docker Compose and try again."
        exit 1
    fi
}

# Build all services
build_all() {
    print_header "Building all SisterCheck services"
    check_docker
    check_docker_compose
    
    print_status "Building API service..."
    docker-compose build api
    
    print_status "Building Python ML service..."
    docker-compose build python-ml
    
    print_status "Building Flutter web service..."
    docker-compose build flutter-web
    
    print_status "All services built successfully!"
}

# Start production environment
start_production() {
    print_header "Starting SisterCheck production environment"
    check_docker
    check_docker_compose
    
    print_status "Starting all services..."
    docker-compose up -d
    
    print_status "Production environment started!"
    print_status "Access the application at: http://localhost:8080"
    print_status "API: http://localhost:5000"
    print_status "ML API: http://localhost:5001"
}

# Start development environment
start_development() {
    print_header "Starting SisterCheck development environment"
    check_docker
    check_docker_compose
    
    print_status "Starting development services..."
    docker-compose -f docker-compose.dev.yml up -d
    
    print_status "Development environment started!"
    print_status "Access the application at: http://localhost:8080"
    print_status "API: http://localhost:5000"
    print_status "ML API: http://localhost:5001"
}

# Stop all services
stop_all() {
    print_header "Stopping all SisterCheck services"
    check_docker
    check_docker_compose
    
    print_status "Stopping production services..."
    docker-compose down
    
    print_status "Stopping development services..."
    docker-compose -f docker-compose.dev.yml down
    
    print_status "All services stopped!"
}

# View logs
view_logs() {
    local service=${2:-"all"}
    
    print_header "Viewing logs for $service"
    check_docker
    check_docker_compose
    
    if [ "$service" = "all" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f $service
    fi
}

# View development logs
view_dev_logs() {
    local service=${2:-"all"}
    
    print_header "Viewing development logs for $service"
    check_docker
    check_docker_compose
    
    if [ "$service" = "all" ]; then
        docker-compose -f docker-compose.dev.yml logs -f
    else
        docker-compose -f docker-compose.dev.yml logs -f $service
    fi
}

# Clean up Docker resources
cleanup() {
    print_header "Cleaning up Docker resources"
    check_docker
    
    print_warning "This will remove all containers, networks, and volumes. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Removing containers..."
        docker-compose down -v
        docker-compose -f docker-compose.dev.yml down -v
        
        print_status "Removing unused containers..."
        docker container prune -f
        
        print_status "Removing unused networks..."
        docker network prune -f
        
        print_status "Removing unused volumes..."
        docker volume prune -f
        
        print_status "Removing unused images..."
        docker image prune -f
        
        print_status "Cleanup completed!"
    else
        print_status "Cleanup cancelled."
    fi
}

# Show status of services
status() {
    print_header "SisterCheck Services Status"
    check_docker
    check_docker_compose
    
    print_status "Production services:"
    docker-compose ps
    
    echo ""
    print_status "Development services:"
    docker-compose -f docker-compose.dev.yml ps
}

# Restart a specific service
restart_service() {
    local service=$2
    if [ -z "$service" ]; then
        print_error "Please specify a service to restart"
        echo "Usage: $0 restart <service-name>"
        exit 1
    fi
    
    print_header "Restarting $service"
    check_docker
    check_docker_compose
    
    print_status "Restarting $service..."
    docker-compose restart $service
    print_status "$service restarted!"
}

# Show help
show_help() {
    echo "SisterCheck Docker Management Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build              Build all Docker images"
    echo "  start              Start production environment"
    echo "  start-dev          Start development environment"
    echo "  stop               Stop all services"
    echo "  logs [service]     View logs (all services or specific service)"
    echo "  logs-dev [service] View development logs"
    echo "  status             Show status of all services"
    echo "  restart <service>  Restart a specific service"
    echo "  cleanup            Clean up Docker resources"
    echo "  help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 start"
    echo "  $0 logs api"
    echo "  $0 restart python-ml"
}

# Main script logic
case "${1:-help}" in
    "build")
        build_all
        ;;
    "start")
        start_production
        ;;
    "start-dev")
        start_development
        ;;
    "stop")
        stop_all
        ;;
    "logs")
        view_logs "$@"
        ;;
    "logs-dev")
        view_dev_logs "$@"
        ;;
    "status")
        status
        ;;
    "restart")
        restart_service "$@"
        ;;
    "cleanup")
        cleanup
        ;;
    "help"|*)
        show_help
        ;;
esac 