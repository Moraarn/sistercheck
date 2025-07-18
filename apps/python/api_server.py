from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import os
import joblib
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.ensemble import RandomForestClassifier
import warnings
from datetime import datetime
import json

warnings.filterwarnings('ignore')

app = Flask(__name__)
CORS(app)

# Global variables to store the trained model and preprocessing objects
model = None
feature_columns = None
target_encoder = None
scaler = None
inventory_data = None
charges_data = None
patient_data = None

def load_model_and_data():
    """Load the trained model and data files"""
    global model, feature_columns, target_encoder, scaler, inventory_data, charges_data, patient_data
    
    try:
        # Load the trained model and preprocessing objects
        model = joblib.load('trained_model.pkl')
        feature_columns = joblib.load('feature_columns.pkl')
        target_encoder = joblib.load('target_encoder.pkl')
        scaler = joblib.load('scaler.pkl')
        
        # Load data files
        inventory_data = pd.read_csv('inventory.csv')
        charges_data = pd.read_csv('hospital_charges.csv')
        patient_data = pd.read_csv('patient_data.csv')
        
        print("✅ Model and data loaded successfully")
        return True
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        return False

def preprocess_patient_data(patient_data):
    """Preprocess patient data for prediction"""
    try:
        # Create DataFrame from patient data
        patient_df = pd.DataFrame([patient_data])
        patient_df.columns = patient_df.columns.str.strip()
        
        # Parse symptoms and create dummy variables
        if 'Reported Sym' in patient_df.columns:
            patient_df['Reported Sym'] = patient_df['Reported Sym'].str.strip().str.replace('"', '').fillna('Unknown')
            symptom_dummies = patient_df['Reported Sym'].str.get_dummies(sep=', ').add_prefix('Symptom_')
            patient_df = pd.concat([patient_df, symptom_dummies], axis=1).drop('Reported Sym', axis=1)
        
        # One-hot encode categorical features
        categorical_cols = ['Menopause Stage', 'Ultrasound Fe']
        for col in categorical_cols:
            if col in patient_df.columns:
                patient_df[col] = patient_df[col].str.strip().str.replace('"', '').fillna('Unknown')
        
        patient_processed = pd.get_dummies(patient_df, columns=categorical_cols, dtype=float)
        
        # Align columns with training features
        final_patient_features = patient_processed.reindex(columns=feature_columns, fill_value=0)
        
        # Scale numerical features
        numerical_cols = ['Age', 'SI Cyst Size cm', 'Cyst Growth', 'fca 125 Level']
        cols_to_scale = [col for col in numerical_cols if col in final_patient_features.columns]
        if cols_to_scale:
            final_patient_features[cols_to_scale] = scaler.transform(final_patient_features[cols_to_scale])
        
        return final_patient_features
    except Exception as e:
        print(f"❌ Error preprocessing data: {e}")
        return None

def get_cost_and_inventory_info(recommended_plan):
    """Get cost and inventory information for the recommended treatment"""
    cost_info = {"status": "Not Available"}
    inventory_info = {"status": "Not Available"}
    
    service_map = {
        'Surgery': ('Ovarian Cystec', 'Speculum'),
        'Medication': ('Pain Managem', 'Paracetamol'),
        'Observation': ('Initial Consult', None),
        'Referral': ('Referral Speci', None)
    }
    
    if recommended_plan in service_map:
        service_name, tool_name = service_map[recommended_plan]
        
        # Find cost information
        cost_row = charges_data[charges_data['Service'].str.contains(service_name, na=False)]
        if not cost_row.empty:
            cost_info = {
                "status": "Available",
                "service": cost_row.iloc[0]['Service'],
                "baseCost": float(cost_row.iloc[0]['Base Cost (KES)']),
                "outOfPocket": float(cost_row.iloc[0]['Out-of-Pocket (KES)']),
                "currency": "KES"
            }
        
        # Find inventory information
        if tool_name:
            inventory_row = inventory_data[inventory_data['Item'].str.contains(tool_name, na=False)]
            if not inventory_row.empty:
                inventory_info = {
                    "status": "Available",
                    "item": inventory_row.iloc[0]['Item'],
                    "availableStock": int(inventory_row.iloc[0]['Available Stock']),
                    "unit": "pieces"
                }
    
    return cost_info, inventory_info

@app.route('/', methods=['GET'])
def root():
    """Root endpoint with API information"""
    return jsonify({
        'api_name': 'Ovarian Cyst Prediction API',
        'version': '1.0.0',
        'description': 'REST API for predicting ovarian cyst treatment plans',
        'endpoints': {
            'health': '/health - Health check endpoint',
            'predict': '/predict - Basic prediction endpoint',
            'care_template': '/care-template - Complete care template with costs',
            'model_info': '/model-info - Model information and statistics',
            'test_samples': '/test-samples - Test with sample patients',
            'validate_input': '/validate-input - Validate patient input data',
            'train': '/train - Retrain the model'
        },
        'timestamp': datetime.now().isoformat()
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None,
        'data_loaded': all([inventory_data is not None, charges_data is not None, patient_data is not None]),
        'timestamp': datetime.now().isoformat(),
        'endpoints_available': [
            '/predict',
            '/care-template', 
            '/model-info',
            '/test-samples',
            '/validate-input'
        ]
    })

@app.route('/model-info', methods=['GET'])
def model_info():
    """Get model information and statistics"""
    if model is None:
        return jsonify({'error': 'Model not loaded'}), 503
    
    try:
        # Get model statistics
        model_stats = {
            'model_type': type(model).__name__,
            'feature_count': len(feature_columns),
            'treatment_classes': list(target_encoder.classes_),
            'class_count': len(target_encoder.classes_),
            'training_samples': len(patient_data) if patient_data is not None else 0
        }
        
        # Get data statistics
        data_stats = {}
        if patient_data is not None:
            data_stats = {
                'total_patients': len(patient_data),
                'age_range': {
                    'min': int(patient_data['Age'].min()),
                    'max': int(patient_data['Age'].max()),
                    'mean': float(patient_data['Age'].mean())
                },
                'cyst_size_range': {
                    'min': float(patient_data['SI Cyst Size cm'].min()),
                    'max': float(patient_data['SI Cyst Size cm'].max()),
                    'mean': float(patient_data['SI Cyst Size cm'].mean())
                },
                'ca125_range': {
                    'min': int(patient_data['fca 125 Level'].min()),
                    'max': int(patient_data['fca 125 Level'].max()),
                    'mean': float(patient_data['fca 125 Level'].mean())
                }
            }
        
        return jsonify({
            'success': True,
            'model_info': model_stats,
            'data_statistics': data_stats,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/validate-input', methods=['POST'])
def validate_input():
    """Validate patient input data"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'valid': False,
                'errors': ['No data provided']
            }), 400
        
        errors = []
        warnings = []
        
        # Required fields
        required_fields = ['Age', 'SI Cyst Size cm', 'Cyst Growth', 'fca 125 Level']
        for field in required_fields:
            if field not in data:
                errors.append(f'Missing required field: {field}')
            elif not isinstance(data[field], (int, float)):
                errors.append(f'Field {field} must be a number')
        
        # Validate ranges
        if 'Age' in data and isinstance(data['Age'], (int, float)):
            if data['Age'] < 0 or data['Age'] > 120:
                warnings.append('Age should be between 0 and 120')
        
        if 'SI Cyst Size cm' in data and isinstance(data['SI Cyst Size cm'], (int, float)):
            if data['SI Cyst Size cm'] < 0 or data['SI Cyst Size cm'] > 20:
                warnings.append('Cyst size should be between 0 and 20 cm')
        
        if 'fca 125 Level' in data and isinstance(data['fca 125 Level'], (int, float)):
            if data['fca 125 Level'] < 0 or data['fca 125 Level'] > 1000:
                warnings.append('CA-125 level should be between 0 and 1000')
        
        # Validate categorical fields
        valid_menopause_stages = ['Pre-menopausi', 'Post-menopausi']
        if 'Menopause Stage' in data:
            if data['Menopause Stage'] not in valid_menopause_stages:
                warnings.append(f'Menopause Stage should be one of: {valid_menopause_stages}')
        
        valid_ultrasound_features = ['Simple cyst', 'Complex cyst', 'Solid mass', 'Septated cyst', 'Hemorrhagic c']
        if 'Ultrasound Fe' in data:
            if data['Ultrasound Fe'] not in valid_ultrasound_features:
                warnings.append(f'Ultrasound Features should be one of: {valid_ultrasound_features}')
        
        return jsonify({
            'valid': len(errors) == 0,
            'errors': errors,
            'warnings': warnings,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/predict', methods=['POST'])
def predict():
    """Predict treatment plan for a patient"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'error': 'No data provided',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        if model is None:
            return jsonify({
                'success': False,
                'error': 'Model not loaded',
                'timestamp': datetime.now().isoformat()
            }), 503
        
        # Preprocess the patient data
        processed_data = preprocess_patient_data(data)
        if processed_data is None:
            return jsonify({
                'success': False,
                'error': 'Failed to preprocess data',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        # Make prediction
        prediction_encoded = model.predict(processed_data)
        recommended_plan = target_encoder.inverse_transform(prediction_encoded)[0]
        
        # Get prediction probabilities
        probabilities = model.predict_proba(processed_data)[0]
        confidence = max(probabilities)
        
        return jsonify({
            'success': True,
            'prediction': recommended_plan,
            'confidence': float(confidence),
            'probabilities': {
                target_encoder.classes_[i]: float(prob) 
                for i, prob in enumerate(probabilities)
            },
            'patient_data': data,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/care-template', methods=['POST'])
def generate_care_template():
    """Generate a complete care template with cost and inventory information"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'error': 'No data provided',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        if model is None:
            return jsonify({
                'success': False,
                'error': 'Model not loaded',
                'timestamp': datetime.now().isoformat()
            }), 503
        
        # Preprocess the patient data
        processed_data = preprocess_patient_data(data)
        if processed_data is None:
            return jsonify({
                'success': False,
                'error': 'Failed to preprocess data',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        # Make prediction
        prediction_encoded = model.predict(processed_data)
        recommended_plan = target_encoder.inverse_transform(prediction_encoded)[0]
        
        # Get prediction probabilities
        probabilities = model.predict_proba(processed_data)[0]
        confidence = max(probabilities)
        
        # Generate cost and inventory information
        cost_info, inventory_info = get_cost_and_inventory_info(recommended_plan)
        
        return jsonify({
            'success': True,
            'prediction': recommended_plan,
            'confidence': float(confidence),
            'probabilities': {
                target_encoder.classes_[i]: float(prob) 
                for i, prob in enumerate(probabilities)
            },
            'cost_info': cost_info,
            'inventory_info': inventory_info,
            'patient_data': data,
            'recommendations': {
                'treatment_plan': recommended_plan,
                'urgency': 'High' if confidence > 0.8 else 'Medium' if confidence > 0.6 else 'Low',
                'follow_up': 'Required' if recommended_plan in ['Surgery', 'Referral'] else 'Recommended'
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/test-samples', methods=['GET'])
def test_samples():
    """Test the model with sample patients from the dataset"""
    try:
        if model is None:
            return jsonify({
                'success': False,
                'error': 'Model not loaded',
                'timestamp': datetime.now().isoformat()
            }), 503
        
        if patient_data is None:
            return jsonify({
                'success': False,
                'error': 'Patient data not loaded',
                'timestamp': datetime.now().isoformat()
            }), 503
        
        # Test with different types of patients
        test_indices = [0, 4, 10, 20, 30, 40, 50]
        results = []
        
        for i, idx in enumerate(test_indices):
            if idx < len(patient_data):
                patient = patient_data.iloc[idx]
                
                # Make prediction
                result = predict_patient(patient)
                if result:
                    results.append({
                        'test_case': i + 1,
                        'patient_id': patient['Patient ID'],
                        'patient_data': {
                            'age': int(patient['Age']),
                            'menopause_stage': patient['Menopause Stage'],
                            'cyst_size': float(patient['SI Cyst Size cm']),
                            'cyst_growth': float(patient['Cyst Growth']),
                            'ca125_level': int(patient['fca 125 Level']),
                            'ultrasound_features': patient['Ultrasound Fe'],
                            'reported_symptoms': patient['Reported Sym']
                        },
                        'prediction_result': result
                    })
        
        return jsonify({
            'success': True,
            'total_tests': len(results),
            'test_results': results,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

def predict_patient(patient):
    """Helper function to predict for a single patient"""
    try:
        # Preprocess the patient data
        processed_data = preprocess_patient_data(patient)
        if processed_data is None:
            return None
        
        # Make prediction
        prediction_encoded = model.predict(processed_data)
        recommended_plan = target_encoder.inverse_transform(prediction_encoded)[0]
        
        # Get prediction probabilities
        probabilities = model.predict_proba(processed_data)[0]
        confidence = max(probabilities)
        
        # Get cost and inventory information
        cost_info, inventory_info = get_cost_and_inventory_info(recommended_plan)
        
        return {
            'prediction': recommended_plan,
            'confidence': float(confidence),
            'probabilities': {
                target_encoder.classes_[i]: float(prob) 
                for i, prob in enumerate(probabilities)
            },
            'cost_info': cost_info,
            'inventory_info': inventory_info
        }
        
    except Exception as e:
        print(f"Error making prediction: {e}")
        return None

@app.route('/train', methods=['POST'])
def train_model():
    """Train the model with new data"""
    try:
        from ovarian_cyst_predictor import preprocess_and_clean, train_and_evaluate
        
        # Load the original data
        original_patient_data = pd.read_csv('patient_data.csv')
        
        # Preprocess and train
        processed_data, target_label_encoder = preprocess_and_clean(original_patient_data)
        model, feature_columns, scaler = train_and_evaluate(processed_data, target_label_encoder)
        
        # Save the trained model and preprocessing objects
        joblib.dump(model, 'trained_model.pkl')
        joblib.dump(feature_columns, 'feature_columns.pkl')
        joblib.dump(target_label_encoder, 'target_encoder.pkl')
        joblib.dump(scaler, 'scaler.pkl')
        
        # Reload the model
        load_model_and_data()
        
        return jsonify({
            'success': True,
            'message': 'Model trained and saved successfully',
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

if __name__ == '__main__':
    # Load the model on startup
    if load_model_and_data():
        print("🚀 Starting API Server...")
        print("📋 Available endpoints:")
        print("  GET  / - API information")
        print("  GET  /health - Health check")
        print("  GET  /model-info - Model information")
        print("  POST /validate-input - Validate input data")
        print("  POST /predict - Basic prediction")
        print("  POST /care-template - Complete care template")
        print("  GET  /test-samples - Test with sample patients")
        print("  POST /train - Retrain model")
        print("🌐 Server running at: http://127.0.0.1:5001")
        app.run(host='127.0.0.1', port=5001, debug=True)
    else:
        print("❌ Failed to load model. Please ensure the model files exist.")
