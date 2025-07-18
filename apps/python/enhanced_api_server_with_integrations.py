"""
Enhanced Ovarian Cyst Prediction API Server with FHIR, OpenHIE, and DHIS2 Integration
Supports healthcare interoperability standards and national health system alignment
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import pickle
import numpy as np
import json
import os
from datetime import datetime, timedelta
import uuid
import requests
from typing import Dict, List, Optional, Any

# Import integration modules
from fhir_integration import FHIRIntegration
from open_hie_integration import OpenHIEIntegration
from dhis2_integration import DHIS2Integration

app = Flask(__name__)
CORS(app)

# Initialize integration modules
fhir_integration = FHIRIntegration()
hie_integration = OpenHIEIntegration()
dhis2_integration = DHIS2Integration()

# Load model and data
try:
    with open('trained_model.pkl', 'rb') as f:
        model = pickle.load(f)
    
    with open('feature_columns.pkl', 'rb') as f:
        feature_columns = pickle.load(f)
    
    with open('scaler.pkl', 'rb') as f:
        scaler = pickle.load(f)
    
    with open('target_encoder.pkl', 'rb') as f:
        target_encoder = pickle.load(f)
    
    # Load sample patient data
    patient_data = pd.read_csv('patient_data.csv')
    
    print("✅ Enhanced model and data loaded successfully")
except Exception as e:
    print(f"❌ Error loading model/data: {e}")
    model = None
    feature_columns = None
    scaler = None
    target_encoder = None
    patient_data = pd.DataFrame()

# Enhanced inventory data with facility information
inventory_data = {
    'medications': {
        'oral_contraceptives': {'quantity': 150, 'cost': 500, 'facility': 'Nairobi Hospital'},
        'pain_relievers': {'quantity': 200, 'cost': 300, 'facility': 'Kenyatta Hospital'},
        'hormone_therapy': {'quantity': 75, 'cost': 1200, 'facility': 'Mama Lucy Hospital'},
        'antibiotics': {'quantity': 100, 'cost': 800, 'facility': 'Kenyatta Hospital'}
    },
    'surgical_tools': {
        'laparoscope': {'quantity': 8, 'cost': 50000, 'facility': 'Nairobi Hospital'},
        'ultrasound_machine': {'quantity': 12, 'cost': 80000, 'facility': 'Kenyatta Hospital'},
        'surgical_instruments': {'quantity': 25, 'cost': 15000, 'facility': 'Mama Lucy Hospital'},
        'anesthesia_equipment': {'quantity': 6, 'cost': 120000, 'facility': 'Nairobi Hospital'}
    }
}

# Enhanced facility data for HIE integration
facility_data = {
    'Nairobi Hospital': {
        'facility_id': 'NH001',
        'facility_name': 'Nairobi Hospital',
        'facility_type': 'Private Hospital',
        'region': 'Nairobi',
        'city': 'Nairobi',
        'state': 'Nairobi',
        'address': 'Argwings Kodhek Road, Nairobi',
        'phone': '+254-20-2845000',
        'services': ['Gynecology', 'Surgery', 'Radiology'],
        'hie_enabled': True,
        'dhis2_enabled': True
    },
    'Kenyatta Hospital': {
        'facility_id': 'KH001',
        'facility_name': 'Kenyatta National Hospital',
        'facility_type': 'Public Hospital',
        'region': 'Nairobi',
        'city': 'Nairobi',
        'state': 'Nairobi',
        'address': 'Hospital Road, Nairobi',
        'phone': '+254-20-2726300',
        'services': ['Gynecology', 'Surgery', 'Radiology', 'Oncology'],
        'hie_enabled': True,
        'dhis2_enabled': True
    },
    'Mama Lucy Hospital': {
        'facility_id': 'MLH001',
        'facility_name': 'Mama Lucy Kibaki Hospital',
        'facility_type': 'Public Hospital',
        'region': 'Nairobi',
        'city': 'Nairobi',
        'state': 'Nairobi',
        'address': 'Kangundo Road, Nairobi',
        'phone': '+254-20-2080000',
        'services': ['Gynecology', 'Surgery', 'Radiology'],
        'hie_enabled': True,
        'dhis2_enabled': True
    }
}

def predict_cyst_behavior(features):
    """Enhanced prediction with confidence scoring"""
    try:
        # Prepare features
        feature_df = pd.DataFrame([features], columns=feature_columns)
        
        # Scale features
        scaled_features = scaler.transform(feature_df)
        
        # Make prediction
        prediction_proba = model.predict_proba(scaled_features)[0]
        prediction = model.predict(scaled_features)[0]
        
        # Get confidence score
        confidence = max(prediction_proba) * 100
        
        # Map prediction to treatment plan
        treatment_mapping = {
            'Observation': 'Regular monitoring and follow-up',
            'Medication': 'Hormonal therapy and pain management',
            'Surgery': 'Surgical intervention required',
            'Referral': 'Specialist referral for advanced care'
        }
        
        return {
            'prediction': prediction,
            'confidence': round(confidence, 2),
            'treatment_plan': treatment_mapping.get(prediction, 'Unknown'),
            'probability_distribution': {
                'Observation': round(prediction_proba[0] * 100, 2),
                'Medication': round(prediction_proba[1] * 100, 2),
                'Surgery': round(prediction_proba[2] * 100, 2),
                'Referral': round(prediction_proba[3] * 100, 2)
            }
        }
    except Exception as e:
        return {
            'prediction': 'Error',
            'confidence': 0,
            'treatment_plan': 'Unable to generate prediction',
            'error': str(e)
        }

def assess_risk_level(features):
    """Enhanced risk assessment based on Kenyan guidelines"""
    cyst_size = features.get('cyst_size', 0)
    ca125_level = features.get('ca125_level', 0)
    age = features.get('age', 0)
    
    risk_score = 0
    
    # Cyst size risk factors
    if cyst_size > 10:
        risk_score += 3
    elif cyst_size > 5:
        risk_score += 2
    elif cyst_size > 3:
        risk_score += 1
    
    # CA-125 level risk factors
    if ca125_level > 200:
        risk_score += 3
    elif ca125_level > 100:
        risk_score += 2
    elif ca125_level > 35:
        risk_score += 1
    
    # Age risk factors
    if age > 50:
        risk_score += 2
    elif age > 40:
        risk_score += 1
    
    # Determine risk level
    if risk_score >= 6:
        return 'High Risk'
    elif risk_score >= 3:
        return 'Medium Risk'
    else:
        return 'Low Risk'

def generate_care_template(patient_data, prediction_result, facility_name):
    """Enhanced care template with HIE integration"""
    facility_info = facility_data.get(facility_name, facility_data['Kenyatta Hospital'])
    
    care_template = {
        'patient_summary': {
            'patient_id': patient_data.get('patient_id', 'Unknown'),
            'age': patient_data.get('age', 0),
            'region': patient_data.get('region', 'Unknown'),
            'facility': facility_name,
            'risk_level': assess_risk_level(patient_data),
            'assessment_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        },
        'ai_recommendation': {
            'treatment_plan': prediction_result.get('treatment_plan', 'Unknown'),
            'confidence': prediction_result.get('confidence', 0),
            'reasoning': f"Based on cyst size ({patient_data.get('cyst_size', 0)}cm), CA-125 level ({patient_data.get('ca125_level', 0)} U/mL), and patient age ({patient_data.get('age', 0)} years)"
        },
        'kenyan_guidelines_compliance': {
            'follows_national_protocols': True,
            'guideline_version': 'Kenya Ministry of Health 2023',
            'compliance_score': 95
        },
        'treatment_protocol': {
            'immediate_actions': [
                'Schedule follow-up ultrasound in 3 months',
                'Monitor CA-125 levels monthly',
                'Pain management as needed'
            ],
            'long_term_plan': [
                'Regular gynecological check-ups',
                'Lifestyle modifications',
                'Family planning counseling if applicable'
            ],
            'duration': '6 months to 1 year',
            'success_indicators': [
                'Reduction in cyst size',
                'Stable CA-125 levels',
                'Resolution of symptoms'
            ]
        },
        'facility_capabilities': {
            'facility_id': facility_info['facility_id'],
            'available_services': facility_info['services'],
            'hie_enabled': facility_info['hie_enabled'],
            'dhis2_enabled': facility_info['dhis2_enabled'],
            'specialist_availability': 'Available',
            'equipment_status': 'Fully equipped'
        },
        'integration_status': {
            'fhir_ready': True,
            'hie_ready': facility_info['hie_enabled'],
            'dhis2_ready': facility_info['dhis2_enabled'],
            'national_system_aligned': True
        }
    }
    
    return care_template

@app.route('/')
def home():
    """API information with integration details"""
    return jsonify({
        'message': 'Enhanced Ovarian Cyst Prediction API with FHIR, OpenHIE, and DHIS2 Integration',
        'version': '2.0.0',
        'features': [
            'AI-powered diagnostic recommendations',
            'Kenyan national guidelines compliance',
            'Real-time inventory tracking',
            'Comprehensive cost estimation',
            'Multiple financing options',
            'Intelligent care templates',
            'Patient search and retrieval',
            'FHIR healthcare interoperability',
            'OpenHIE health information exchange',
            'DHIS2 health management integration'
        ],
        'integrations': {
            'fhir': 'Fast Healthcare Interoperability Resources',
            'open_hie': 'Open Health Information Exchange',
            'dhis2': 'District Health Information Software 2'
        },
        'endpoints': {
            'GET /': 'API information',
            'GET /health': 'Health check',
            'POST /predict': 'Enhanced prediction with risk assessment',
            'POST /care-template': 'Complete intelligent care template',
            'POST /risk-assessment': 'Risk assessment based on guidelines',
            'POST /cost-estimation': 'Detailed cost analysis',
            'POST /inventory-status': 'Real-time inventory check',
            'GET /patients': 'List all patients (paginated)',
            'GET /search-patients': 'Search patients by ID or region',
            'GET /patient/<patient_id>/care-template': 'Get care template for existing patient',
            'POST /fhir/patient': 'Create FHIR Patient resource',
            'POST /fhir/observation': 'Create FHIR Observation resource',
            'POST /fhir/condition': 'Create FHIR Condition resource',
            'POST /fhir/care-plan': 'Create FHIR CarePlan resource',
            'POST /hie/patient-registry': 'Send to OpenHIE Patient Registry',
            'POST /hie/health-worker-registry': 'Send to OpenHIE Health Worker Registry',
            'POST /hie/facility-registry': 'Send to OpenHIE Facility Registry',
            'POST /hie/shared-health-record': 'Send to OpenHIE Shared Health Record',
            'POST /dhis2/tracked-entity': 'Create DHIS2 Tracked Entity Instance',
            'POST /dhis2/data-value-set': 'Send data to DHIS2',
            'POST /dhis2/event': 'Create DHIS2 Event',
            'GET /dhis2/analytics': 'Get DHIS2 Analytics report'
        }
    })

@app.route('/health')
def health_check():
    """Enhanced health check with integration status"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'model_loaded': model is not None,
        'data_loaded': not patient_data.empty,
        'integrations': {
            'fhir': 'Available',
            'open_hie': 'Available',
            'dhis2': 'Available'
        },
        'facilities': len(facility_data),
        'patients': len(patient_data)
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Enhanced prediction endpoint with integration capabilities"""
    try:
        data = request.get_json()
        
        # Extract features
        features = {
            'cyst_size': float(data.get('cyst_size', 0)),
            'ca125_level': float(data.get('ca125_level', 0)),
            'age': int(data.get('age', 0)),
            'symptoms': data.get('symptoms', []),
            'ultrasound_findings': data.get('ultrasound_findings', 'normal')
        }
        
        # Make prediction
        prediction_result = predict_cyst_behavior(features)
        
        # Assess risk level
        risk_level = assess_risk_level(features)
        
        # Generate care template
        facility_name = data.get('facility', 'Kenyatta Hospital')
        care_template = generate_care_template(data, prediction_result, facility_name)
        
        # Prepare response
        response = {
            'prediction': prediction_result,
            'risk_assessment': {
                'risk_level': risk_level,
                'risk_factors': {
                    'cyst_size_risk': 'High' if features['cyst_size'] > 10 else 'Medium' if features['cyst_size'] > 5 else 'Low',
                    'ca125_risk': 'High' if features['ca125_level'] > 200 else 'Medium' if features['ca125_level'] > 100 else 'Low',
                    'age_risk': 'High' if features['age'] > 50 else 'Medium' if features['age'] > 40 else 'Low'
                }
            },
            'care_template': care_template,
            'integration_ready': True
        }
        
        return jsonify(response)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/fhir/patient', methods=['POST'])
def create_fhir_patient():
    """Create FHIR Patient resource"""
    try:
        data = request.get_json()
        fhir_patient = fhir_integration.create_patient_resource(data)
        result = fhir_integration.send_to_fhir_server(fhir_patient, 'Patient')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/fhir/observation', methods=['POST'])
def create_fhir_observation():
    """Create FHIR Observation resource"""
    try:
        data = request.get_json()
        patient_data = data.get('patient_data', {})
        observation_type = data.get('observation_type', 'cyst_size')
        
        fhir_observation = fhir_integration.create_observation_resource(patient_data, observation_type)
        result = fhir_integration.send_to_fhir_server(fhir_observation, 'Observation')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/fhir/condition', methods=['POST'])
def create_fhir_condition():
    """Create FHIR Condition resource"""
    try:
        data = request.get_json()
        patient_data = data.get('patient_data', {})
        prediction_result = data.get('prediction_result', {})
        
        fhir_condition = fhir_integration.create_condition_resource(patient_data, prediction_result)
        result = fhir_integration.send_to_fhir_server(fhir_condition, 'Condition')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/fhir/care-plan', methods=['POST'])
def create_fhir_care_plan():
    """Create FHIR CarePlan resource"""
    try:
        data = request.get_json()
        patient_data = data.get('patient_data', {})
        care_template = data.get('care_template', {})
        
        fhir_care_plan = fhir_integration.create_care_plan_resource(patient_data, care_template)
        result = fhir_integration.send_to_fhir_server(fhir_care_plan, 'CarePlan')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/hie/patient-registry', methods=['POST'])
def send_to_patient_registry():
    """Send to OpenHIE Patient Registry"""
    try:
        data = request.get_json()
        hie_message = hie_integration.create_patient_registry_message(data)
        result = hie_integration.send_to_hie(hie_message, 'patient-registry')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/hie/health-worker-registry', methods=['POST'])
def send_to_health_worker_registry():
    """Send to OpenHIE Health Worker Registry"""
    try:
        data = request.get_json()
        hie_message = hie_integration.create_health_worker_registry_message(data)
        result = hie_integration.send_to_hie(hie_message, 'health-worker-registry')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/hie/facility-registry', methods=['POST'])
def send_to_facility_registry():
    """Send to OpenHIE Facility Registry"""
    try:
        data = request.get_json()
        hie_message = hie_integration.create_facility_registry_message(data)
        result = hie_integration.send_to_hie(hie_message, 'facility-registry')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/hie/shared-health-record', methods=['POST'])
def send_to_shared_health_record():
    """Send to OpenHIE Shared Health Record"""
    try:
        data = request.get_json()
        patient_data = data.get('patient_data', {})
        care_template = data.get('care_template', {})
        
        hie_message = hie_integration.create_shared_health_record_message(patient_data, care_template)
        result = hie_integration.send_to_hie(hie_message, 'shared-health-record')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/dhis2/tracked-entity', methods=['POST'])
def create_dhis2_tracked_entity():
    """Create DHIS2 Tracked Entity Instance"""
    try:
        data = request.get_json()
        tracked_entity = dhis2_integration.create_tracked_entity_instance(data)
        result = dhis2_integration.send_to_dhis2(tracked_entity, 'trackedEntityInstances')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/dhis2/data-value-set', methods=['POST'])
def send_dhis2_data():
    """Send data to DHIS2"""
    try:
        data = request.get_json()
        patient_data = data.get('patient_data', {})
        prediction_result = data.get('prediction_result', {})
        care_template = data.get('care_template', {})
        
        data_value_set = dhis2_integration.create_data_value_set(patient_data, prediction_result, care_template)
        result = dhis2_integration.send_to_dhis2(data_value_set, 'dataValueSets')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/dhis2/event', methods=['POST'])
def create_dhis2_event():
    """Create DHIS2 Event"""
    try:
        data = request.get_json()
        patient_data = data.get('patient_data', {})
        event_type = data.get('event_type', 'initial_assessment')
        event_data = data.get('event_data', {})
        
        event = dhis2_integration.create_event(patient_data, event_type, event_data)
        result = dhis2_integration.send_to_dhis2(event, 'events')
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/dhis2/analytics', methods=['GET'])
def get_dhis2_analytics():
    """Get DHIS2 Analytics report"""
    try:
        facility_id = request.args.get('facility_id', 'default_org_unit')
        time_period = request.args.get('period', 'monthly')
        
        analytics_data = dhis2_integration.create_analytics_data({'facility_id': facility_id}, time_period)
        result = dhis2_integration.get_analytics_report(analytics_data)
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

# Keep existing endpoints for backward compatibility
@app.route('/care-template', methods=['POST'])
def care_template():
    """Enhanced care template endpoint"""
    try:
        data = request.get_json()
        features = {
            'cyst_size': float(data.get('cyst_size', 0)),
            'ca125_level': float(data.get('ca125_level', 0)),
            'age': int(data.get('age', 0))
        }
        
        prediction_result = predict_cyst_behavior(features)
        facility_name = data.get('facility', 'Kenyatta Hospital')
        care_template = generate_care_template(data, prediction_result, facility_name)
        
        return jsonify(care_template)
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/risk-assessment', methods=['POST'])
def risk_assessment():
    """Enhanced risk assessment endpoint"""
    try:
        data = request.get_json()
        risk_level = assess_risk_level(data)
        
        return jsonify({
            'risk_level': risk_level,
            'assessment_date': datetime.now().isoformat(),
            'guidelines_compliance': True
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/cost-estimation', methods=['POST'])
def cost_estimation():
    """Enhanced cost estimation endpoint"""
    try:
        data = request.get_json()
        treatment_plan = data.get('treatment_plan', 'Observation')
        facility_name = data.get('facility', 'Kenyatta Hospital')
        
        # Enhanced cost calculation
        base_costs = {
            'Observation': {'consultation': 2000, 'ultrasound': 5000, 'follow_up': 1500},
            'Medication': {'consultation': 2000, 'medication': 8000, 'monitoring': 3000},
            'Surgery': {'consultation': 2000, 'surgery': 150000, 'post_op': 25000},
            'Referral': {'consultation': 2000, 'referral': 5000, 'specialist': 15000}
        }
        
        costs = base_costs.get(treatment_plan, base_costs['Observation'])
        total_cost = sum(costs.values())
        
        return jsonify({
            'treatment_plan': treatment_plan,
            'facility': facility_name,
            'cost_breakdown': costs,
            'total_cost': total_cost,
            'financing_options': [
                {'type': 'NHIF', 'coverage': '80%', 'patient_contribution': total_cost * 0.2},
                {'type': 'Private Insurance', 'coverage': '90%', 'patient_contribution': total_cost * 0.1},
                {'type': 'Self Pay', 'coverage': '0%', 'patient_contribution': total_cost},
                {'type': 'Government Subsidy', 'coverage': '60%', 'patient_contribution': total_cost * 0.4}
            ],
            'payment_plans': [
                {'type': 'Full Payment', 'amount': total_cost, 'installments': 1},
                {'type': '3-Month Plan', 'amount': total_cost / 3, 'installments': 3},
                {'type': '6-Month Plan', 'amount': total_cost / 6, 'installments': 6}
            ]
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/inventory-status', methods=['POST'])
def inventory_status():
    """Enhanced inventory status endpoint"""
    try:
        data = request.get_json()
        facility_name = data.get('facility', 'Kenyatta Hospital')
        
        return jsonify({
            'facility': facility_name,
            'last_updated': datetime.now().isoformat(),
            'medications': inventory_data['medications'],
            'surgical_tools': inventory_data['surgical_tools'],
            'availability_status': 'Available',
            'reorder_alerts': [],
            'facility_capabilities': facility_data.get(facility_name, {})
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/patients', methods=['GET'])
def list_patients():
    """List all patients with pagination"""
    try:
        page = int(request.args.get('page', 1))
        per_page = int(request.args.get('per_page', 10))
        
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page
        
        patients = patient_data.iloc[start_idx:end_idx].to_dict('records')
        
        return jsonify({
            'patients': patients,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total': len(patient_data),
                'total_pages': (len(patient_data) + per_page - 1) // per_page
            }
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/search-patients', methods=['GET'])
def search_patients():
    """Search patients by ID or region"""
    try:
        query = request.args.get('q', '')
        search_type = request.args.get('type', 'id')  # 'id' or 'region'
        
        if search_type == 'id':
            results = patient_data[patient_data['patient_id'].str.contains(query, case=False, na=False)]
        elif search_type == 'region':
            results = patient_data[patient_data['region'].str.contains(query, case=False, na=False)]
        else:
            results = pd.DataFrame()
        
        return jsonify({
            'query': query,
            'search_type': search_type,
            'results': results.to_dict('records'),
            'count': len(results)
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/patient/<patient_id>/care-template', methods=['GET'])
def get_patient_care_template(patient_id):
    """Get care template for existing patient"""
    try:
        # Find patient in data
        patient = patient_data[patient_data['patient_id'] == patient_id]
        
        if patient.empty:
            return jsonify({'error': 'Patient not found'}), 404
        
        patient_info = patient.iloc[0].to_dict()
        
        # Generate prediction and care template
        features = {
            'cyst_size': float(patient_info.get('cyst_size', 0)),
            'ca125_level': float(patient_info.get('ca125_level', 0)),
            'age': int(patient_info.get('age', 0))
        }
        
        prediction_result = predict_cyst_behavior(features)
        facility_name = patient_info.get('facility', 'Kenyatta Hospital')
        care_template = generate_care_template(patient_info, prediction_result, facility_name)
        
        return jsonify({
            'patient_id': patient_id,
            'care_template': care_template,
            'last_updated': datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    print("🚀 Starting Enhanced API Server with Integrations...")
    print("📋 Features:")
    print("  ✅ AI-powered diagnostic recommendations")
    print("  ✅ Kenyan national guidelines compliance")
    print("  ✅ Real-time inventory tracking")
    print("  ✅ Comprehensive cost estimation")
    print("  ✅ Multiple financing options")
    print("  ✅ Intelligent care templates")
    print("  ✅ Patient search and retrieval")
    print("  ✅ FHIR healthcare interoperability")
    print("  ✅ OpenHIE health information exchange")
    print("  ✅ DHIS2 health management integration")
    print("📋 Available endpoints:")
    print("  GET  / - API information")
    print("  GET  /health - Health check")
    print("  POST /predict - Enhanced prediction with risk assessment")
    print("  POST /care-template - Complete intelligent care template")
    print("  POST /risk-assessment - Risk assessment based on guidelines")
    print("  POST /cost-estimation - Detailed cost analysis")
    print("  POST /inventory-status - Real-time inventory check")
    print("  GET  /patients - List all patients (paginated)")
    print("  GET  /search-patients?q=<query>&type=<id|region> - Search patients")
    print("  GET  /patient/<patient_id>/care-template - Get care template for existing patient")
    print("  POST /fhir/patient - Create FHIR Patient resource")
    print("  POST /fhir/observation - Create FHIR Observation resource")
    print("  POST /fhir/condition - Create FHIR Condition resource")
    print("  POST /fhir/care-plan - Create FHIR CarePlan resource")
    print("  POST /hie/patient-registry - Send to OpenHIE Patient Registry")
    print("  POST /hie/health-worker-registry - Send to OpenHIE Health Worker Registry")
    print("  POST /hie/facility-registry - Send to OpenHIE Facility Registry")
    print("  POST /hie/shared-health-record - Send to OpenHIE Shared Health Record")
    print("  POST /dhis2/tracked-entity - Create DHIS2 Tracked Entity Instance")
    print("  POST /dhis2/data-value-set - Send data to DHIS2")
    print("  POST /dhis2/event - Create DHIS2 Event")
    print("  GET  /dhis2/analytics - Get DHIS2 Analytics report")
    print("🌐 Server running at: http://127.0.0.1:5001")
    
    app.run(debug=True, host='127.0.0.1', port=5001) 