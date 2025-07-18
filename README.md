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
└── README.md           # This file
```

## 🚀 Quick Start

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

## 📋 Features

- **Risk Assessment**: AI-powered health risk evaluation
- **Care Templates**: Personalized care plans
- **Educational Content**: Audio lessons and health information
- **Clinic Finder**: Locate nearby healthcare facilities
- **Crystal AI**: Advanced AI chat assistance
- **Analytics**: Comprehensive health data analysis

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details 