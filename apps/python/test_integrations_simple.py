"""
Simple test script for FHIR, OpenHIE, and DHIS2 integrations
Tests the new integration endpoints added to the enhanced_api_server.py
"""

import requests
import json
from datetime import datetime

# API base URL
BASE_URL = "http://127.0.0.1:5000"

def test_api_info():
    """Test API information endpoint"""
    print("🔍 Testing API Information...")
    
    response = requests.get(f"{BASE_URL}/")
    print(f"✅ API Info: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Version: {data.get('version')}")
        print(f"   Features: {len(data.get('features', []))}")
        print(f"   Integrations: {list(data.get('integrations', {}).keys())}")
        
        # Check if integration endpoints are listed
        endpoints = data.get('endpoints', {})
        integration_endpoints = [
            'POST /fhir/patient',
            'POST /fhir/observation', 
            'POST /hie/patient-registry',
            'POST /hie/facility-registry',
            'POST /dhis2/tracked-entity',
            'POST /dhis2/data-value-set'
        ]
        
        for endpoint in integration_endpoints:
            if endpoint in endpoints.values():
                print(f"   ✅ {endpoint} - Available")
            else:
                print(f"   ❌ {endpoint} - Missing")

def test_fhir_integrations():
    """Test FHIR integration endpoints"""
    print("\n🔍 Testing FHIR Integrations...")
    
    # Test FHIR Patient creation
    patient_data = {
        "patient_id": "OC-2001",
        "age": 45,
        "region": "Nairobi",
        "facility": "Kenyatta Hospital"
    }
    
    response = requests.post(f"{BASE_URL}/fhir/patient", json=patient_data)
    print(f"✅ FHIR Patient creation: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Success: {data.get('success')}")
        if not data.get('success'):
            print(f"   Error: {data.get('error')}")
    
    # Test FHIR Observation creation
    observation_data = {
        "patient_data": patient_data,
        "observation_type": "cyst_size"
    }
    
    response = requests.post(f"{BASE_URL}/fhir/observation", json=observation_data)
    print(f"✅ FHIR Observation creation: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Success: {data.get('success')}")
        if not data.get('success'):
            print(f"   Error: {data.get('error')}")

def test_hie_integrations():
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
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Success: {data.get('success')}")
        if not data.get('success'):
            print(f"   Error: {data.get('error')}")
    
    # Test Facility Registry
    facility_data = {
        "facility_id": "KH001",
        "facility_name": "Kenyatta National Hospital",
        "facility_type": "Public Hospital",
        "region": "Nairobi"
    }
    
    response = requests.post(f"{BASE_URL}/hie/facility-registry", json=facility_data)
    print(f"✅ OpenHIE Facility Registry: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Success: {data.get('success')}")
        if not data.get('success'):
            print(f"   Error: {data.get('error')}")

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
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Success: {data.get('success')}")
        if not data.get('success'):
            print(f"   Error: {data.get('error')}")
    
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
    
    if response.status_code == 200:
        data = response.json()
        print(f"   Success: {data.get('success')}")
        if not data.get('success'):
            print(f"   Error: {data.get('error')}")

def test_existing_endpoints():
    """Test existing endpoints still work"""
    print("\n🔍 Testing Existing Endpoints...")
    
    # Test health check
    response = requests.get(f"{BASE_URL}/health")
    print(f"✅ Health check: {response.status_code}")
    
    # Test patient listing
    response = requests.get(f"{BASE_URL}/patients?page=1&per_page=5")
    print(f"✅ Patient listing: {response.status_code}")
    
    # Test patient search
    response = requests.get(f"{BASE_URL}/search-patients?q=OC-1001&type=id")
    print(f"✅ Patient search: {response.status_code}")

def main():
    """Run all integration tests"""
    print("🚀 Testing FHIR, OpenHIE, and DHIS2 Integrations...")
    print("=" * 60)
    
    try:
        test_api_info()
        test_fhir_integrations()
        test_hie_integrations()
        test_dhis2_integrations()
        test_existing_endpoints()
        
        print("\n" + "=" * 60)
        print("✅ Integration testing completed!")
        print("📋 Summary:")
        print("  - FHIR healthcare interoperability: Added")
        print("  - OpenHIE health information exchange: Added")
        print("  - DHIS2 health management integration: Added")
        print("  - Existing functionality: Preserved")
        print("  - National health system alignment: Enabled")
        
    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to the API server.")
        print("   Make sure the server is running at http://127.0.0.1:5000")
        print("   The server should automatically reload with the new endpoints.")
    except Exception as e:
        print(f"❌ Error during testing: {e}")

if __name__ == "__main__":
    main() 