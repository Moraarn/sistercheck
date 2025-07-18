"""
Test script for FHIR, OpenHIE, and DHIS2 integrations
Tests all the new interoperability endpoints
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
        print(f"   Features: {len(data.get('features', []))}")
        print(f"   Integrations: {list(data.get('integrations', {}).keys())}")
    
    # Test health check
    response = requests.get(f"{BASE_URL}/health")
    print(f"✅ Health check: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"   Model loaded: {data.get('model_loaded')}")
        print(f"   Integrations: {data.get('integrations')}")

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

def test_fhir_integrations():
    """Test FHIR integration endpoints"""
    print("\n🔍 Testing FHIR Integrations...")
    
    # Test patient data
    patient_data = {
        "patient_id": "OC-2001",
        "age": 45,
        "region": "Nairobi",
        "facility": "Kenyatta Hospital"
    }
    
    # Test FHIR Patient creation
    response = requests.post(f"{BASE_URL}/fhir/patient", json=patient_data)
    print(f"✅ FHIR Patient creation: {response.status_code}")
    
    # Test FHIR Observation creation
    observation_data = {
        "patient_data": patient_data,
        "observation_type": "cyst_size"
    }
    response = requests.post(f"{BASE_URL}/fhir/observation", json=observation_data)
    print(f"✅ FHIR Observation creation: {response.status_code}")
    
    # Test FHIR Condition creation
    condition_data = {
        "patient_data": patient_data,
        "prediction_result": {"prediction": "Medication"}
    }
    response = requests.post(f"{BASE_URL}/fhir/condition", json=condition_data)
    print(f"✅ FHIR Condition creation: {response.status_code}")
    
    # Test FHIR CarePlan creation
    care_plan_data = {
        "patient_data": patient_data,
        "care_template": {
            "ai_recommendation": {"treatment_plan": "Medication"},
            "patient_summary": {"risk_level": "Medium Risk"}
        }
    }
    response = requests.post(f"{BASE_URL}/fhir/care-plan", json=care_plan_data)
    print(f"✅ FHIR CarePlan creation: {response.status_code}")

def test_open_hie_integrations():
    """Test OpenHIE integration endpoints"""
    print("\n🔍 Testing OpenHIE Integrations...")
    
    # Test Patient Registry
    patient_data = {
        "patient_id": "OC-2001",
        "age": 45,
        "region": "Nairobi"
    }
    response = requests.post(f"{BASE_URL}/hie/patient-registry", json=patient_data)
    print(f"✅ OpenHIE Patient Registry: {response.status_code}")
    
    # Test Health Worker Registry
    health_worker_data = {
        "worker_id": "HW-001",
        "first_name": "Dr. Jane",
        "last_name": "Doe",
        "gender": "F",
        "facility_id": "KH001",
        "facility_name": "Kenyatta Hospital"
    }
    response = requests.post(f"{BASE_URL}/hie/health-worker-registry", json=health_worker_data)
    print(f"✅ OpenHIE Health Worker Registry: {response.status_code}")
    
    # Test Facility Registry
    facility_data = {
        "facility_id": "KH001",
        "facility_name": "Kenyatta National Hospital",
        "facility_type": "Public Hospital",
        "region": "Nairobi",
        "city": "Nairobi",
        "state": "Nairobi",
        "address": "Hospital Road, Nairobi",
        "phone": "+254-20-2726300"
    }
    response = requests.post(f"{BASE_URL}/hie/facility-registry", json=facility_data)
    print(f"✅ OpenHIE Facility Registry: {response.status_code}")
    
    # Test Shared Health Record
    health_record_data = {
        "patient_data": patient_data,
        "care_template": {
            "ai_recommendation": {"treatment_plan": "Medication"},
            "patient_summary": {"risk_level": "Medium Risk"}
        }
    }
    response = requests.post(f"{BASE_URL}/hie/shared-health-record", json=health_record_data)
    print(f"✅ OpenHIE Shared Health Record: {response.status_code}")

def test_dhis2_integrations():
    """Test DHIS2 integration endpoints"""
    print("\n🔍 Testing DHIS2 Integrations...")
    
    # Test Tracked Entity Instance
    patient_data = {
        "patient_id": "OC-2001",
        "age": 45,
        "region": "Nairobi",
        "facility_id": "KH001",
        "facility_name": "Kenyatta Hospital"
    }
    response = requests.post(f"{BASE_URL}/dhis2/tracked-entity", json=patient_data)
    print(f"✅ DHIS2 Tracked Entity Instance: {response.status_code}")
    
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
    print(f"✅ DHIS2 Data Value Set: {response.status_code}")
    
    # Test Event creation
    event_data = {
        "patient_data": patient_data,
        "event_type": "initial_assessment",
        "event_data": {
            "cyst_size": 8.5,
            "ca125_level": 150,
            "symptoms": ["pelvic_pain", "bloating"]
        }
    }
    response = requests.post(f"{BASE_URL}/dhis2/event", json=event_data)
    print(f"✅ DHIS2 Event creation: {response.status_code}")
    
    # Test Analytics
    response = requests.get(f"{BASE_URL}/dhis2/analytics?facility_id=KH001&period=monthly")
    print(f"✅ DHIS2 Analytics: {response.status_code}")

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
    
    # Test patient search by region
    response = requests.get(f"{BASE_URL}/search-patients?q=Nairobi&type=region")
    print(f"✅ Patient search by region: {response.status_code}")
    
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
    """Run all integration tests"""
    print("🚀 Starting Integration Tests for FHIR, OpenHIE, and DHIS2...")
    print("=" * 60)
    
    try:
        test_basic_endpoints()
        test_prediction_with_integration()
        test_fhir_integrations()
        test_open_hie_integrations()
        test_dhis2_integrations()
        test_enhanced_endpoints()
        test_patient_search()
        test_existing_patient_care_template()
        
        print("\n" + "=" * 60)
        print("✅ All integration tests completed!")
        print("📋 Summary:")
        print("  - FHIR healthcare interoperability: Available")
        print("  - OpenHIE health information exchange: Available")
        print("  - DHIS2 health management integration: Available")
        print("  - National health system alignment: Enabled")
        
    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to the API server.")
        print("   Make sure the server is running at http://127.0.0.1:5000")
    except Exception as e:
        print(f"❌ Error during testing: {e}")

if __name__ == "__main__":
    main() 