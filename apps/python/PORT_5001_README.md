# SisterCheck Python API Server - Port 5001

## 🚀 Server Configuration

The SisterCheck Python API server has been configured to run on **port 5001** instead of port 5000.

## 📋 Available Servers

### 1. Enhanced API Server (Full Features)
```bash
python enhanced_api_server.py
```
- **Port**: 5001
- **URL**: http://127.0.0.1:5001
- **Features**: Complete AI-driven care templates, risk assessment, cost estimation, inventory tracking, FHIR/HIE/DHIS2 integration

### 2. Enhanced API Server (Simple)
```bash
python enhanced_api_server_simple.py
```
- **Port**: 5001
- **URL**: http://127.0.0.1:5001
- **Features**: Simplified version with core functionality

### 3. Enhanced API Server (With Integrations)
```bash
python enhanced_api_server_with_integrations.py
```
- **Port**: 5001
- **URL**: http://127.0.0.1:5001
- **Features**: Full features with advanced FHIR/HIE/DHIS2 integrations

### 4. Basic API Server
```bash
python app.py
```
- **Port**: 5001
- **URL**: http://127.0.0.1:5001
- **Features**: Basic prediction and care template generation

### 5. Simple API Server
```bash
python api_server.py
```
- **Port**: 5001
- **URL**: http://127.0.0.1:5001
- **Features**: Simple prediction API

## 🛠️ Quick Start

### Option 1: Use the Start Script
```bash
python start_server.py
```
This will show you a menu to select which server to run.

### Option 2: Direct Execution
```bash
# For the main enhanced server
python enhanced_api_server.py

# For simple server
python enhanced_api_server_simple.py
```

## 🔗 API Endpoints

All servers provide these endpoints on port 5001:

- `GET /` - API information
- `GET /health` - Health check
- `POST /predict` - Enhanced prediction with risk assessment
- `POST /care-template` - Complete intelligent care template
- `POST /risk-assessment` - Risk assessment based on guidelines
- `POST /cost-estimation` - Detailed cost analysis
- `POST /inventory-status` - Real-time inventory check
- `GET /patients` - List all patients (paginated)
- `GET /search-patients` - Search patients
- `GET /patient/<id>/care-template` - Get care template for patient

## 📱 Flutter App Configuration

The Flutter app has been updated to connect to port 5001:

- **Network Configuration**: `lib/plugins/network_constant.dart`
- **Base URL**: Updated to use port 5001
- **Dev Tunnel**: Updated to use port 5001

## 🔧 Troubleshooting

### Port Already in Use
If port 5001 is already in use, you can:

1. **Find the process using port 5001**:
   ```bash
   # On Windows
   netstat -ano | findstr :5001
   
   # On Linux/Mac
   lsof -i :5001
   ```

2. **Kill the process**:
   ```bash
   # Replace PID with the actual process ID
   kill -9 <PID>
   ```

### Change Port Manually
If you need to use a different port, edit the server file and change:
```python
app.run(host='127.0.0.1', port=5001, debug=True)
```
to your desired port number.

## 📊 Health Check

Test if the server is running:
```bash
curl http://127.0.0.1:5001/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2025-01-XX...",
  "port": 5001
}
```

## 🎯 Next Steps

1. Start the Python server on port 5001
2. Run the Flutter app
3. Test the doctor's dashboard features
4. Verify all endpoints are working correctly

---

**Note**: Make sure to update any external services or configurations that were pointing to port 5000 to now use port 5001. 