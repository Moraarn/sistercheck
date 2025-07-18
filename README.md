# SisterCheck Monorepo

A comprehensive healthcare application with three main components:

## 📁 Project Structure

```
sistercheck/
├── apps/
│   ├── flutter/          # Flutter mobile application
│   ├── api/             # Node.js REST API
│   └── python/          # Python ML backend
├── package.json         # Root package.json for monorepo
├── docker-compose.yml   # Production Docker Compose
├── docker-compose.dev.yml # Development Docker Compose
├── docker-scripts.sh    # Docker management script
├── nginx/               # Nginx configurations
└── README.md           # This file
```

## 🐳 Docker Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Git

### Quick Setup with Docker

1. **Clone and navigate to the project:**
   ```bash
   git clone <repository-url>
   cd sistercheck
   ```

2. **Build and start all services:**
   ```bash
   # Build all Docker images
   ./docker-scripts.sh build
   
   # Start production environment
   ./docker-scripts.sh start
   ```

3. **Access the application:**
   - **Web App**: http://localhost:8080
   - **API**: http://localhost:5000
   - **ML API**: http://localhost:5001

### Development Environment

```bash
# Start development environment with hot reloading
./docker-scripts.sh start-dev

# View development logs
./docker-scripts.sh logs-dev

# Stop all services
./docker-scripts.sh stop
```

### Docker Management Commands

```bash
# Build all services
./docker-scripts.sh build

# Start production environment
./docker-scripts.sh start

# Start development environment
./docker-scripts.sh start-dev

# Stop all services
./docker-scripts.sh stop

# View logs
./docker-scripts.sh logs [service-name]

# View development logs
./docker-scripts.sh logs-dev [service-name]

# Check service status
./docker-scripts.sh status

# Restart a specific service
./docker-scripts.sh restart <service-name>

# Clean up Docker resources
./docker-scripts.sh cleanup

# Show help
./docker-scripts.sh help
```

## 🚀 Manual Setup (Alternative)

### Prerequisites
- Node.js 18+
- Python 3.8+
- Flutter 3.0+
- Git

### Installation

1. **Install root dependencies:**
   ```bash
   npm install
   ```

2. **Install API dependencies:**
   ```bash
   cd apps/api && npm install
   ```

3. **Install Python dependencies:**
   ```bash
   cd apps/python && pip install -r requirements.txt
   ```

4. **Install Flutter dependencies:**
   ```bash
   cd apps/flutter && flutter pub get
   ```

### Development

**Start all services:**
```bash
npm run start:all
```

**Start individual services:**
```bash
# API only
npm run dev:api

# Python backend only
npm run dev:python

# Flutter (in separate terminal)
cd apps/flutter && flutter run
```

## 📱 Apps

### Flutter App (`apps/flutter/`)
- Mobile application for patients
- Risk assessment features
- Care template management
- Audio lessons and educational content

### Node.js API (`apps/api/`)
- REST API for the Flutter app
- User authentication and management
- Risk assessment data processing
- Integration with external services

### Python Backend (`apps/python/`)
- Machine learning models
- Risk assessment algorithms
- Data processing and analytics
- DHIS2 integration

## 🔧 Development Scripts

- `npm run dev:api` - Start Node.js API in development mode
- `npm run dev:python` - Start Python ML backend
- `npm run build:api` - Build Node.js API
- `npm run install:all` - Install all dependencies
- `npm run test:api` - Run API tests
- `npm run start:all` - Start both API and Python backend

## 🐳 Docker Services

### Production Services
- **API**: Node.js REST API (Port 5000)
- **Python ML**: Machine Learning backend (Port 5001)
- **Flutter Web**: Web application (Port 80)
- **MongoDB**: Database (Port 27017)
- **Redis**: Cache (Port 6379)
- **Nginx**: Reverse proxy (Port 443/8080)

### Development Services
- **API Dev**: Node.js API with hot reloading
- **Python ML Dev**: Python backend with debug mode
- **Flutter Web Dev**: Flutter web with hot reloading
- **MongoDB Dev**: Development database
- **Redis Dev**: Development cache
- **Nginx Dev**: Development reverse proxy

## 📋 Features

- **Risk Assessment**: AI-powered health risk evaluation
- **Care Templates**: Personalized care plans
- **Educational Content**: Audio lessons and health information
- **Clinic Finder**: Locate nearby healthcare facilities
- **Crystal AI**: Advanced AI chat assistance
- **Analytics**: Comprehensive health data analysis

## 🔒 Security Features

- **HTTPS**: SSL/TLS encryption in production
- **Rate Limiting**: API request rate limiting
- **Security Headers**: Comprehensive security headers
- **Non-root Users**: Containers run as non-root users
- **Health Checks**: Automated health monitoring
- **CORS**: Proper CORS configuration

## 🚀 Deployment

### Production Deployment
```bash
# Build and start production environment
./docker-scripts.sh build
./docker-scripts.sh start

# View logs
./docker-scripts.sh logs

# Monitor services
./docker-scripts.sh status
```

### Environment Variables
Create `.env` files in each app directory with appropriate configuration:

**API (.env):**
```
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb://admin:sistercheck123@mongodb:27017/sistercheck
JWT_SECRET=your-jwt-secret
```

**Python (.env):**
```
FLASK_ENV=production
PORT=5001
MONGODB_URI=mongodb://admin:sistercheck123@mongodb:27017/sistercheck
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details 