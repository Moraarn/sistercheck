# AI Model Integration Guide

This guide documents the integration of the ovarian cyst prediction model with the SisterCheck backend API and Flutter frontend.

## Overview

The integration consists of three main components:
1. **Python AI Model** - Flask API serving the trained machine learning model
2. **Node.js Backend** - Enhanced with care template management and AI integration
3. **Flutter Frontend** - New screens to display AI-generated care templates

## Architecture

```
┌─────────────────┐    HTTP    ┌─────────────────┐    HTTP    ┌─────────────────┐
│   Flutter App   │ ────────── │  Node.js API    │ ────────── │  Python AI API  │
│                 │            │                 │            │                 │
│ - Care Template │            │ - Care Template │            │ - Prediction    │
│ - History       │            │ - Symptoms      │            │ - Care Template │
│ - Treatment     │            │ - Risk Assessment│           │ - Cost Info     │
└─────────────────┘            └─────────────────┘            └─────────────────┘
```

## Setup Instructions

### 1. Python AI Model Setup

Navigate to the `sistercheck-python` directory:

```bash
cd sistercheck-python
```

Install dependencies:
```bash
pip install -r requirements.txt
```

Train the model:
```bash
python train_model.py
```

Start the Flask API:
```bash
python app.py
```

The Python API will be available at `http://localhost:5000`

### 2. Node.js Backend Setup

Navigate to the `sistercheck-api` directory:

```bash
cd sistercheck-api
```

Install dependencies:
```bash
npm install
```

Set environment variables in `.env`:
```env
PYTHON_API_URL=http://localhost:5000
```

Start the development server:
```bash
npm run dev
```

### 3. Flutter Frontend Setup

Navigate to the `codeher` directory:

```bash
cd codeher
```

Install dependencies:
```bash
flutter pub get
```

Run the app:
```bash
flutter run
```

## API Endpoints

### Python AI API (`http://localhost:5000`)

- `GET /health` - Health check
- `POST /predict` - Get treatment prediction
- `POST /care-template` - Generate complete care template
- `POST /train` - Retrain the model

### Node.js Backend API

#### Care Templates
- `POST /care-template` - Create care template with AI prediction
- `GET /care-template/latest` - Get user's latest care template
- `GET /care-template` - Get all care templates for user
- `GET /care-template/:id` - Get specific care template
- `PUT /care-template/:id` - Update care template
- `DELETE /care-template/:id` - Delete care template
- `GET /care-template/status/:status` - Get care templates by status
- `GET /care-template/stats` - Get care template statistics

#### Enhanced Symptoms
- `POST /symptoms` - Create symptoms (automatically generates care template)
- All existing symptom endpoints remain unchanged

#### Enhanced Risk Assessment
- `POST /risk-assessment` - Create risk assessment (automatically generates care template)
- All existing risk assessment endpoints remain unchanged

## Data Flow

### 1. Symptom Entry Flow
1. User enters symptoms in Flutter app
2. Flutter sends symptom data to Node.js API
3. Node.js saves symptoms to database
4. Node.js automatically calls Python AI API with symptom data
5. Python AI processes data and returns prediction
6. Node.js creates care template with AI results
7. Flutter displays care template to user

### 2. Risk Assessment Flow
1. User completes risk assessment in Flutter app
2. Flutter sends assessment data to Node.js API
3. Node.js saves assessment to database
4. Node.js automatically calls Python AI API with assessment data
5. Python AI processes data and returns prediction
6. Node.js creates care template with AI results
7. Flutter displays care template to user

## Care Template Structure

```typescript
interface CareTemplate {
  userId: string;
  symptomId?: string;
  riskAssessmentId?: string;
  patientData: {
    age?: number;
    menopauseStage?: string;
    cystSize?: number;
    cystGrowth?: number;
    fca125Level?: number;
    ultrasoundFeatures?: string;
    reportedSymptoms?: string;
  };
  prediction: {
    treatmentPlan: string; // 'Surgery', 'Medication', 'Observation', 'Referral'
    confidence: number; // 0-1
    probabilities?: Map<string, number>;
  };
  carePlan: {
    costInfo: {
      service?: string;
      baseCost?: number;
      outOfPocket?: number;
    };
    inventoryInfo: {
      item?: string;
      availableStock?: number;
    };
    recommendations: string[];
    nextSteps: string[];
  };
  status: 'pending' | 'approved' | 'in_progress' | 'completed';
}
```

## Flutter Screens

### 1. Care Template Screen (`care_template_screen.dart`)
- Displays detailed care template information
- Shows AI prediction with confidence score
- Lists recommendations and next steps
- Displays cost and inventory information

### 2. Care Template History Screen (`care_template_history_screen.dart`)
- Lists all care templates for the user
- Filter by status (pending, approved, in_progress, completed)
- Tap to view detailed care template

### 3. Enhanced Home Screen
- Added "Care Templates" and "Track Symptoms" cards
- Quick access to AI-powered features

## AI Model Features

### Treatment Plans
- **Surgery**: For severe cases requiring surgical intervention
- **Medication**: For moderate cases requiring pharmaceutical treatment
- **Observation**: For mild cases requiring monitoring
- **Referral**: For cases requiring specialist consultation

### Confidence Scoring
- AI model provides confidence scores (0-100%)
- Higher confidence indicates more reliable predictions
- Used to guide treatment decisions

### Cost and Inventory Integration
- Automatically matches treatment plans with available services
- Provides cost estimates in Kenyan Shillings (KES)
- Checks inventory availability for required items

## Error Handling

### Python API Errors
- Network timeouts (30 seconds)
- Model loading failures
- Data preprocessing errors
- Graceful fallback to default recommendations

### Node.js Integration Errors
- Care template creation failures don't affect symptom/assessment saving
- Automatic retry mechanisms for AI API calls
- Detailed error logging for debugging

### Flutter App Errors
- Network error handling with user-friendly messages
- Loading states for better UX
- Graceful degradation when AI features are unavailable

## Security Considerations

1. **Authentication**: All care template endpoints require user authentication
2. **Data Privacy**: Patient data is only processed for the requesting user
3. **API Security**: Python API should be deployed with proper security measures
4. **Input Validation**: All inputs are validated before processing

## Monitoring and Logging

### Python API Logs
- Model prediction requests and responses
- Training completion status
- Error details for debugging

### Node.js Backend Logs
- Care template creation events
- AI API call success/failure rates
- User interaction patterns

### Flutter App Analytics
- Care template view counts
- User engagement with AI features
- Feature usage statistics

## Future Enhancements

1. **User Profile Integration**: Use actual user age and medical history
2. **Medical Data Integration**: Connect with ultrasound and blood test results
3. **Real-time Updates**: Push notifications for care template updates
4. **Advanced Analytics**: Track treatment outcomes and model accuracy
5. **Multi-language Support**: Localize care templates for different regions

## Troubleshooting

### Common Issues

1. **Python API not responding**
   - Check if Flask server is running on port 5000
   - Verify model files exist in the directory
   - Check Python dependencies are installed

2. **Care templates not generating**
   - Verify PYTHON_API_URL environment variable
   - Check Node.js logs for AI API call errors
   - Ensure user authentication is working

3. **Flutter app not loading care templates**
   - Check network connectivity
   - Verify API endpoints are accessible
   - Check authentication token is valid

### Debug Commands

```bash
# Check Python API health
curl http://localhost:5000/health

# Test prediction endpoint
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"Age": 30, "Reported Sym": "Bloating, Pelvic Pain"}'

# Check Node.js API health
curl http://localhost:3000/
```

## Support

For technical support or questions about the integration:
1. Check the logs for error details
2. Verify all services are running
3. Test individual components in isolation
4. Review the API documentation 