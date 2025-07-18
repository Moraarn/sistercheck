#!/usr/bin/env python3
"""
Test script for Patient Search functionality
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://127.0.0.1:5000"

def test_health():
    print("🔍 Testing Health Check...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            print("✅ Server is running!")
            return True
        else:
            print("❌ Server not responding")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_search_patient():
    print("\n🔍 Testing Patient Search...")
    try:
        # Search for patient OC-1001
        response = requests.get(f"{BASE_URL}/search-patients?q=OC-1001&type=id")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Found {data['total_results']} patient(s)")
            if data['patients']:
                patient = data['patients'][0]
                print(f"   Patient ID: {patient['patient_id']}")
                print(f"   Age: {patient['age']}")
                print(f"   Cyst Size: {patient['cyst_size']} cm")
                print(f"   Region: {patient['region']}")
        else:
            print(f"❌ Error: {response.json()}")
    except Exception as e:
        print(f"❌ Error: {e}")

def test_care_template():
    print("\n🏥 Testing Care Template for Existing Patient...")
    try:
        # Get care template for patient OC-1001
        response = requests.get(f"{BASE_URL}/patient/OC-1001/care-template")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            care_template = data['care_template']
            
            print("✅ Care Template Generated!")
            print(f"   Patient ID: {care_template['patient_id']}")
            print(f"   Age: {care_template['patient_summary']['age']}")
            print(f"   AI Recommendation: {care_template['ai_recommendation']['treatment_plan']}")
            print(f"   Confidence: {care_template['ai_recommendation']['confidence']:.2%}")
            print(f"   Previous Recommendation: {care_template['patient_summary']['previous_recommendation']}")
            print(f"   Recommendation Changed: {care_template['comparison']['recommendation_changed']}")
        else:
            print(f"❌ Error: {response.json()}")
    except Exception as e:
        print(f"❌ Error: {e}")

def test_list_patients():
    print("\n📋 Testing Patient List...")
    try:
        response = requests.get(f"{BASE_URL}/patients?page=1&per_page=5")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Total Patients: {data['pagination']['total_patients']}")
            print(f"   Patients on page 1:")
            for i, patient in enumerate(data['patients']):
                print(f"   {i+1}. {patient['patient_id']} - Age: {patient['age']}, Region: {patient['region']}")
        else:
            print(f"❌ Error: {response.json()}")
    except Exception as e:
        print(f"❌ Error: {e}")

def main():
    print("🚀 Starting Patient Search Tests")
    print("="*40)
    
    if not test_health():
        print("\n❌ Please start the server first: python enhanced_api_server.py")
        return
    
    test_search_patient()
    test_care_template()
    test_list_patients()
    
    print("\n✅ All tests completed!")

if __name__ == "__main__":
    main() 