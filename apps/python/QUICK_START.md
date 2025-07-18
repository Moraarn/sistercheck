# SisterCheck Python AI Service - Quick Start Guide

## 🚀 Quick Start

### Which File Should You Run?

**For most users, run the main enhanced API server:**
```bash
python enhanced_api_server.py
```

**Alternative options:**
- `python enhanced_api_server_simple.py` - Simplified version with minimal dependencies
- `python enhanced_api_server_with_integrations.py` - Full version with external integration modules
- `python api_server.py` - Basic version (legacy)

### Prerequisites Check

```bash
# Check Python version (should be 3.8+)
python --version

# Check if pip is available
pip --version

# Check if virtual environment is recommended
python -m venv --help
```

### 5-Minute Setup

1. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the server**
   ```bash
   python enhanced_api_server.py
   ```

3. **Test the API**
   ```bash
   # Health check
   curl http://localhost:5001/health
   
   # Test prediction
   curl -X POST http://localhost:5001/predict \
     -H "Content-Type: application/json" \
     -d '{
       "Age": 35,
       "SI Cyst Size cm": 4.5,
       "Cyst Growth": 0.2,
       "fca 125 Level": 45,
       "Menopause Stage": "Pre-menopausi",
       "Ultrasound Fe": "Simple cyst",
       "Reported Sym": "Pelvic Pain, Bloating"
     }'
   ```

### Common Issues & Solutions

**Issue: "No module named 'flask'**
```bash
pip install flask flask-cors
```

**Issue: "No module named 'sklearn'**
```bash
pip install scikit-learn
```

**Issue: "Port 5001 already in use"**
```bash
# Find and kill the process
lsof -i :5001
kill -9 <PID>
```

**Issue: "Model files not found"**
```bash
# Retrain the model
python train_model.py
```

### API Endpoints Quick Reference

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API information |
| `/health` | GET | Health check |
| `/predict` | POST | Basic prediction |
| `/care-template` | POST | Complete care template |
| `/risk-assessment` | POST | Risk assessment |
| `/cost-estimation` | POST | Cost analysis |
| `/inventory-status` | POST | Inventory check |
| `/patients` | GET | List patients |
| `/search-patients` | GET | Search patients |

### Sample API Calls

**Basic Prediction:**
```bash
curl -X POST http://localhost:5001/predict \
  -H "Content-Type: application/json" \
  -d '{
    "Age": 35,
    "SI Cyst Size cm": 4.5,
    "Cyst Growth": 0.2,
    "fca 125 Level": 45,
    "Menopause Stage": "Pre-menopausi",
    "Ultrasound Fe": "Simple cyst",
    "Reported Sym": "Pelvic Pain, Bloating"
  }'
```

**Care Template:**
```bash
curl -X POST http://localhost:5001/care-template \
  -H "Content-Type: application/json" \
  -d '{
    "Age": 35,
    "SI Cyst Size cm": 4.5,
    "Cyst Growth": 0.2,
    "fca 125 Level": 45,
    "Menopause Stage": "Pre-menopausi",
    "Ultrasound Fe": "Simple cyst",
    "Reported Sym": "Pelvic Pain, Bloating",
    "facility": "Kenyatta Hospital"
  }'
```

**Search Patients:**
```bash
curl "http://localhost:5001/search-patients?q=OC-001&type=id"
```

### Development Mode

For development with auto-reload:
```bash
# Set environment variables
export FLASK_ENV=development
export FLASK_DEBUG=True

# Run with debug mode
python enhanced_api_server.py
```

### Production Mode

For production deployment:
```bash
# Install production dependencies
pip install gunicorn

# Run with Gunicorn
gunicorn -w 4 -b 0.0.0.0:5001 enhanced_api_server:app
```

### Docker Quick Start

```bash
# Build image
docker build -t sistercheck-ai .

# Run container
docker run -p 5001:5001 sistercheck-ai
```

### Testing the Service

```bash
# Run the test client
python test_api_client.py

# Test integrations
python test_integrations.py

# Test patient search
python test_patient_search.py
```

### Next Steps

1. **Read the full documentation**: [README.md](README.md)
2. **Explore the API**: Visit http://localhost:5001/ for API information
3. **Test endpoints**: Use the sample API calls above
4. **Integrate with your app**: Use the API endpoints in your application

### Support

- **Documentation**: [README.md](README.md)
- **Issues**: [GitHub Issues](https://github.com/your-username/sistercheck/issues)
- **Email**: support@sistercheck.com

---

**Happy coding! 🚀** 