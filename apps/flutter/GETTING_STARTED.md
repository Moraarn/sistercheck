# SisterCheck - Getting Started Guide

<div align="center">

**Quick start guide for running the SisterCheck women's health platform**

</div>

## 🚀 Which Files Should You Run?

### **Main Answer: Run These Files in Order**

1. **Backend API** (Node.js)
   ```bash
   cd sistercheck-api
   npm install
   npm run dev
   ```

2. **AI Service** (Python)
   ```bash
   cd sistercheck-python
   pip install -r requirements.txt
   python enhanced_api_server.py
   ```

3. **Mobile App** (Flutter)
   ```bash
   flutter pub get
   flutter run
   ```

---

## 📋 Detailed File Selection Guide

### 🤖 Python AI Service Files

**Main file to run:**
```bash
python enhanced_api_server.py
```

**Alternative options:**
- `python enhanced_api_server_simple.py` - Simplified version (minimal dependencies)
- `python enhanced_api_server_with_integrations.py` - Full version with external integrations
- `python api_server.py` - Basic version (legacy)

**Quick start for Python service:**
```bash
cd sistercheck-python
pip install -r requirements.txt
python enhanced_api_server.py
```

### 🔧 Node.js Backend API Files

**Main file to run:**
```bash
npm run dev
```

**Alternative options:**
- `npm start` - Production mode
- `npm run build` - Build for production
- `node dist/index.js` - Run built version

**Quick start for backend API:**
```bash
cd sistercheck-api
npm install
npm run dev
```

### 📱 Flutter Mobile App Files

**Main file to run:**
```bash
flutter run
```

**Alternative options:**
- `flutter run -d android` - Android only
- `flutter run -d ios` - iOS only
- `flutter run -d chrome` - Web version

**Quick start for Flutter app:**
```bash
flutter pub get
flutter run
```

---

## 🏗️ Complete System Startup

### Option 1: Manual Startup (Recommended for Development)

1. **Start Backend API**
   ```bash
   cd sistercheck-api
   npm install
   npm run dev
   # Server runs on http://localhost:3000
   ```

2. **Start AI Service**
   ```bash
   cd sistercheck-python
   pip install -r requirements.txt
   python enhanced_api_server.py
   # Server runs on http://localhost:5001
   ```

3. **Start Flutter App**
   ```bash
   flutter pub get
   flutter run
   # App connects to backend APIs
   ```

### Option 2: Using Scripts

**Start all services:**
```bash
./start_system.sh
```

**Stop all services:**
```bash
./stop_system.sh
```

### Option 3: Docker (Production)

```bash
# Start all services with Docker Compose
docker-compose up -d
```

---

## 🔍 File Descriptions

### Python AI Service Files

| File | Purpose | When to Use |
|------|---------|-------------|
| `enhanced_api_server.py` | **Main AI service** | **Use this for most cases** |
| `enhanced_api_server_simple.py` | Simplified version | Minimal dependencies, Python 3.13+ |
| `enhanced_api_server_with_integrations.py` | Full integrations | External FHIR/OpenHIE/DHIS2 modules |
| `api_server.py` | Basic version | Legacy, basic features only |
| `app.py` | Standard Flask app | Alternative basic version |

### Node.js Backend Files

| File | Purpose | When to Use |
|------|---------|-------------|
| `npm run dev` | **Development server** | **Use this for development** |
| `npm start` | Production server | Use for production |
| `npm run build` | Build application | Before deployment |

### Flutter App Files

| File | Purpose | When to Use |
|------|---------|-------------|
| `flutter run` | **Development mode** | **Use this for development** |
| `flutter build apk` | Build Android APK | For Android distribution |
| `flutter build ios` | Build iOS app | For iOS distribution |
| `flutter build web` | Build web app | For web deployment |

---

## 🛠️ Prerequisites

### System Requirements

- **Operating System**: Windows 10+, macOS 10.15+, Ubuntu 18.04+
- **Memory**: 8GB RAM minimum, 16GB recommended
- **Storage**: 10GB free space
- **Network**: Internet connection for dependencies

### Required Software

1. **Git** (2.30+)
   ```bash
   git --version
   ```

2. **Flutter SDK** (3.8.1+)
   ```bash
   flutter --version
   ```

3. **Node.js** (18+)
   ```bash
   node --version
   npm --version
   ```

4. **Python** (3.13+ recommended, 3.8+ minimum)
   ```bash
   python --version
   pip --version
   ```

5. **MongoDB** (4.4+)
   ```bash
   mongod --version
   ```

---

## 🚨 Common Issues & Solutions

### Python AI Service Issues

**Issue: "No module named 'flask'"**
```bash
pip install flask flask-cors
```

**Issue: "Port 5001 already in use"**
```bash
lsof -i :5001
kill -9 <PID>
```

**Issue: "Model files not found"**
```bash
python train_model.py
```

### Node.js Backend Issues

**Issue: "Port 3000 already in use"**
```bash
lsof -i :3000
kill -9 <PID>
```

**Issue: "MongoDB connection failed"**
```bash
# Start MongoDB
sudo systemctl start mongod
# Or with Docker
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

### Flutter App Issues

**Issue: "Flutter not found"**
```bash
# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"
```

**Issue: "Dependencies not found"**
```bash
flutter clean
flutter pub get
```

---

## 📊 System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │◄──►│  Node.js API    │◄──►│  Python AI      │
│   (Frontend)    │    │   (Backend)     │    │   (ML Service)  │
│                 │    │                 │    │                 │
│ flutter run     │    │ npm run dev     │    │ enhanced_api_   │
│                 │    │                 │    │ server.py       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
   Mobile/Web UI         User Management         AI Predictions
   Patient Portal        Authentication         Healthcare Analytics
   Provider Dashboard    Business Logic         Risk Assessment
```

---

## 🎯 Quick Commands Reference

### Development Commands

```bash
# Start all services
./start_system.sh

# Stop all services
./stop_system.sh

# Check system status
curl http://localhost:3000/health  # Backend API
curl http://localhost:5001/health  # AI Service
```

### Testing Commands

```bash
# Test Flutter app
flutter test

# Test backend API
cd sistercheck-api && npm test

# Test AI service
cd sistercheck-python && pytest
```

### Building Commands

```bash
# Build Flutter app
flutter build apk --release

# Build backend API
cd sistercheck-api && npm run build

# Build AI service (Docker)
cd sistercheck-python && docker build -t sistercheck-ai .
```

---

## 📞 Support

### Getting Help

1. **Check Documentation**
   - [Main README](README.md)
   - [Flutter App README](lib/README.md)
   - [Backend API README](sistercheck-api/README.md)
   - [AI Service README](sistercheck-python/README.md)

2. **Quick Start Guides**
   - [Python AI Service Quick Start](sistercheck-python/QUICK_START.md)
   - [Integration Guide](INTEGRATION_GUIDE.md)
   - [Backend Integration](BACKEND_INTEGRATION.md)

3. **Community Support**
   - [GitHub Issues](https://github.com/your-username/sistercheck/issues)
   - [GitHub Discussions](https://github.com/your-username/sistercheck/discussions)
   - Email: support@sistercheck.com

### Troubleshooting

- **System won't start**: Check prerequisites and ports
- **API errors**: Verify backend services are running
- **AI predictions fail**: Check model files and Python dependencies
- **App crashes**: Check Flutter version and dependencies

---

<div align="center">

**Happy coding! 🚀**

**Made with ❤️ for Women's Health**

</div> 