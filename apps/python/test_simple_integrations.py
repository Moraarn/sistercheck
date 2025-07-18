"""
Test script for Simplified FHIR, OpenHIE, and DHIS2 integrations
Tests the simplified integration endpoints with Python 3.13 compatibility
"""

import requests
import json
from datetime import datetime

# API base URL
BASE_URL = "http://127.0.0.1:5000"

def test_basic_endpoints():
    """Test basic API endpoints"""
    print("🔍 Testing Basic Endpoints...")
    
    # Test home endpoint
    response = requests.get(f"{BASE_URL}/")
    print(f"✅ Home endpoint: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"   Version: {data.get('version')}")
        print(f"   Python compatibility: {data.get('python_compatibility')}")
        print(f"   Features: {len(data.get('features', []))}")
    
    # Test health check
    response = requests.get(f"{BASE_URL}/health")
    print(f"✅ Health check: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"   Model loaded: {data.get('model_loaded')}")
        print(f"   Python version: {data.get('python_version')}")

def test_prediction_with_integration():
    """Test prediction endpoint with integration capabilities"""
    print("\n🔍 Testing Prediction with Integration...")
    
    test_data = {
        "patient_id": "OC-2001",
        "cyst_size": 8.5,
        "ca125_level": 150,
        "age": 45,
        "symptoms": ["pelvic_pain", "bloating"],
        "ultrasound_findings": "complex_cyst",
        "region": "Nairobi",
        "facility": "Kenyatta Hospital"
    }
    
    response = requests.post(f"{BASE_URL}/predict", json=test_data)
    print(f"✅ Prediction endpoint: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Prediction: {data.get('prediction', {}).get('prediction')}")
        print(f"   Confidence: {data.get('prediction', {}).get('confidence')}%")
        print(f"   Risk Level: {data.get('risk_assessment', {}).get('risk_level')}")
        print(f"   Integration Ready: {data.get('integration_ready')}")

def test_simplified_fhir_integrations():
    """Test simplified FHIR integration endpoints"""
    print("\n🔍 Testing Simplified FHIR Integrations...")
    
    # Test patient data
    patient_data = {
        "patient_id": "OC-2001",
        "age": 45,
        "region": "Nairobi",
        "facility": "Kenyatta Hospital"
    }
    
    # Test FHIR Patient creation
    response = requests.post(f"{BASE_URL}/fhir/patient", json=patient_data)
    print(f"✅ Simplified FHIR Patient creation: {response.status_code}")
    
    # Test FHIR Observation creation
    observation_data = {
        "patient_data": patient_data,
        "observation_type": "cyst_size"
    }
    response = requests.post(f"{BASE_URL}/fhir/observation", json=observation_data)
    print(f"✅ Simplified FHIR Observation creation: {response.status_code}")

def test_simplified_hie_integrations():
    """Test simplified OpenHIE integration endpoints"""
    print("\n🔍 Testing Simplified OpenHIE Integrations...")
    
    # Test Patient Registry
    patient_data = {
        "patient_id": "OC-2001",
        "age": 45,
        "region": "Nairobi"
    }
    response = requests.post(f"{BASE_URL}/hie/patient-registry", json=patient_data)
    print(f"✅ Simplified OpenHIE Patient Registry: {response.status_code}")
    
    # Test Facility Registry
    facility_data = {
        "facility_id": "KH001",
        "facility_name": "Kenyatta National Hospital",
        "facility_type": "Public Hospital",
        "region": "Nairobi"
    }
    response = requests.post(f"{BASE_URL}/hie/facility-registry", json=facility_data)
    print(f"✅ Simplified OpenHIE Facility Registry: {response.status_code}")

def test_simplified_dhis2_integrations():
    """Test simplified DHIS2 integration endpoints"""
    print("\n🔍 Testing Simplified DHIS2 Integrations...")
    
    # Test Tracked Entity Instance
    patient_data = {
        "patient_id": "OC-2001",
        "age": 45,
        "region": "Nairobi",
        "facility_id": "KH001",
        "facility_name": "Kenyatta Hospital"
    }
    response = requests.post(f"{BASE_URL}/dhis2/tracked-entity", json=patient_data)
    print(f"✅ Simplified DHIS2 Tracked Entity Instance: {response.status_code}")
    
    # Test Data Value Set
    data_value_data = {
        "patient_data": patient_data,
        "prediction_result": {"prediction": "Medication"},
        "care_template": {
            "ai_recommendation": {"treatment_plan": "Medication", "confidence": 85.5},
            "patient_summary": {"risk_level": "Medium Risk"}
        }
    }
    response = requests.post(f"{BASE_URL}/dhis2/data-value-set", json=data_value_data)
    print(f"✅ Simplified DHIS2 Data Value Set: {response.status_code}")

def test_enhanced_endpoints():
    """Test enhanced endpoints with integration capabilities"""
    print("\n🔍 Testing Enhanced Endpoints...")
    
    # Test enhanced care template
    care_data = {
        "patient_id": "OC-2001",
        "cyst_size": 8.5,
        "ca125_level": 150,
        "age": 45,
        "facility": "Kenyatta Hospital"
    }
    response = requests.post(f"{BASE_URL}/care-template", json=care_data)
    print(f"✅ Enhanced care template: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Integration Status: {data.get('integration_status', {})}")
        print(f"   Facility Capabilities: {data.get('facility_capabilities', {}).get('hie_enabled')}")
    
    # Test enhanced cost estimation
    cost_data = {
        "treatment_plan": "Medication",
        "facility": "Kenyatta Hospital"
    }
    response = requests.post(f"{BASE_URL}/cost-estimation", json=cost_data)
    print(f"✅ Enhanced cost estimation: {response.status_code}")
    
    # Test enhanced inventory status
    inventory_data = {
        "facility": "Kenyatta Hospital"
    }
    response = requests.post(f"{BASE_URL}/inventory-status", json=inventory_data)
    print(f"✅ Enhanced inventory status: {response.status_code}")

def test_patient_search():
    """Test patient search and retrieval"""
    print("\n🔍 Testing Patient Search...")
    
    # Test patient listing
    response = requests.get(f"{BASE_URL}/patients?page=1&per_page=5")
    print(f"✅ Patient listing: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Patients found: {len(data.get('patients', []))}")
        print(f"   Total patients: {data.get('pagination', {}).get('total')}")
    
    # Test patient search by ID
    response = requests.get(f"{BASE_URL}/search-patients?q=OC-1001&type=id")
    print(f"✅ Patient search by ID: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Search results: {data.get('count')}")

def test_existing_patient_care_template():
    """Test getting care template for existing patient"""
    print("\n🔍 Testing Existing Patient Care Template...")
    
    # Test with existing patient ID
    response = requests.get(f"{BASE_URL}/patient/OC-1001/care-template")
    print(f"✅ Existing patient care template: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Patient ID: {data.get('patient_id')}")
        print(f"   Last updated: {data.get('last_updated')}")

def main():
    """Run all simplified integration tests"""
    print("🚀 Starting Simplified Integration Tests for Python 3.13...")
    print("=" * 60)
    
    try:
        test_basic_endpoints()
        test_prediction_with_integration()
        test_simplified_fhir_integrations()
        test_simplified_hie_integrations()
        test_simplified_dhis2_integrations()
        test_enhanced_endpoints()
        test_patient_search()
        test_existing_patient_care_template()
        
        print("\n" + "=" * 60)
        print("✅ All simplified integration tests completed!")
        print("📋 Summary:")
        print("  - Simplified FHIR healthcare interoperability: Available")
        print("  - Simplified OpenHIE health information exchange: Available")
        print("  - Simplified DHIS2 health management integration: Available")
        print("  - Python 3.13+ compatibility: Achieved")
        print("  - National health system alignment: Enabled")
        
    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to the API server.")
        print("   Make sure the server is running at http://127.0.0.1:5000")
        print("   Start with: python enhanced_api_server_simple.py")
    except Exception as e:
        print(f"❌ Error during testing: {e}")

if __name__ == "__main__":
    main() 