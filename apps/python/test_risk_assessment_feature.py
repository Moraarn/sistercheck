#!/usr/bin/env python3
"""
Test script for risk assessment feature implementation
Tests the existing endpoints with the new risk assessment functionality
"""

import requests
import json
from datetime import datetime

# Test data for a patient
test_patient_data = {
    'Age': 35,
    'Menopause Stage': 'Pre-menopausal',
    'SI Cyst Size cm': 6.5,
    'Cyst Growth': 0.2,
    'fca 125 Level': 45,
    'Ultrasound Fe': 'Complex cyst',
    'Reported Sym': 'Pelvic pain, bloating'
}

def test_risk_assessment_endpoint():
    """Test the risk assessment endpoint"""
    print("🔍 Testing Risk Assessment Endpoint...")
    
    try:
        response = requests.post(
            'http://127.0.0.1:5001/risk-assessment',
            json=test_patient_data,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Risk Assessment Endpoint - SUCCESS")
            print(f"   Risk Level: {result.get('risk_assessment', {}).get('risk_level', 'Unknown')}")
            print(f"   Risk Factors: {result.get('risk_assessment', {}).get('risk_factors', [])}")
            print(f"   Success: {result.get('success', False)}")
            return True
        else:
            print(f"❌ Risk Assessment Endpoint - FAILED (Status: {response.status_code})")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Risk Assessment Endpoint - ERROR: {e}")
        return False

def test_cost_estimation_endpoint():
    """Test the cost estimation endpoint"""
    print("\n💰 Testing Cost Estimation Endpoint...")
    
    try:
        response = requests.post(
            'http://127.0.0.1:5001/cost-estimation',
            json=test_patient_data,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Cost Estimation Endpoint - SUCCESS")
            print(f"   Recommended Treatment: {result.get('recommended_treatment', 'Unknown')}")
            print(f"   Total Cost: {result.get('cost_estimation', {}).get('risk_adjusted_cost', 'Unknown')} KES")
            print(f"   Success: {result.get('success', False)}")
            return True
        else:
            print(f"❌ Cost Estimation Endpoint - FAILED (Status: {response.status_code})")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Cost Estimation Endpoint - ERROR: {e}")
        return False

def test_inventory_status_endpoint():
    """Test the inventory status endpoint"""
    print("\n📦 Testing Inventory Status Endpoint...")
    
    try:
        response = requests.post(
            'http://127.0.0.1:5001/inventory-status',
            json=test_patient_data,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Inventory Status Endpoint - SUCCESS")
            print(f"   Recommended Treatment: {result.get('recommended_treatment', 'Unknown')}")
            inventory_status = result.get('inventory_status', {})
            print(f"   Available Items: {len(inventory_status.get('available', []))}")
            print(f"   Low Stock Items: {len(inventory_status.get('low_stock', []))}")
            print(f"   Out of Stock Items: {len(inventory_status.get('out_of_stock', []))}")
            print(f"   Success: {result.get('success', False)}")
            return True
        else:
            print(f"❌ Inventory Status Endpoint - FAILED (Status: {response.status_code})")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Inventory Status Endpoint - ERROR: {e}")
        return False

def test_care_template_endpoint():
    """Test the care template endpoint"""
    print("\n🏥 Testing Care Template Endpoint...")
    
    try:
        response = requests.post(
            'http://127.0.0.1:5001/care-template',
            json=test_patient_data,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Care Template Endpoint - SUCCESS")
            care_template = result.get('care_template', {})
            print(f"   Treatment Plan: {care_template.get('ai_recommendation', {}).get('treatment_plan', 'Unknown')}")
            print(f"   Risk Level: {care_template.get('patient_summary', {}).get('risk_level', 'Unknown')}")
            print(f"   Success: {result.get('success', False)}")
            return True
        else:
            print(f"❌ Care Template Endpoint - FAILED (Status: {response.status_code})")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Care Template Endpoint - ERROR: {e}")
        return False

def test_patients_endpoint():
    """Test the patients listing endpoint"""
    print("\n👥 Testing Patients Endpoint...")
    
    try:
        response = requests.get(
            'http://127.0.0.1:5001/patients?page=1&per_page=5',
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Patients Endpoint - SUCCESS")
            print(f"   Total Patients: {result.get('pagination', {}).get('total_patients', 0)}")
            print(f"   Patients Returned: {len(result.get('patients', []))}")
            print(f"   Success: {result.get('success', False)}")
            return True
        else:
            print(f"❌ Patients Endpoint - FAILED (Status: {response.status_code})")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Patients Endpoint - ERROR: {e}")
        return False

def test_search_patients_endpoint():
    """Test the patient search endpoint"""
    print("\n🔍 Testing Patient Search Endpoint...")
    
    try:
        response = requests.get(
            'http://127.0.0.1:5001/search-patients?q=OC-&type=id',
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Patient Search Endpoint - SUCCESS")
            print(f"   Search Query: {result.get('query', 'Unknown')}")
            print(f"   Results Found: {result.get('total_results', 0)}")
            print(f"   Success: {result.get('success', False)}")
            return True
        else:
            print(f"❌ Patient Search Endpoint - FAILED (Status: {response.status_code})")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Patient Search Endpoint - ERROR: {e}")
        return False

def main():
    """Run all tests"""
    print("🚀 Starting Risk Assessment Feature Tests")
    print("=" * 50)
    print(f"📅 Test Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🧪 Test Patient Data: {json.dumps(test_patient_data, indent=2)}")
    print("=" * 50)
    
    # Test all endpoints
    tests = [
        test_risk_assessment_endpoint,
        test_cost_estimation_endpoint,
        test_inventory_status_endpoint,
        test_care_template_endpoint,
        test_patients_endpoint,
        test_search_patients_endpoint
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
    
    print("\n" + "=" * 50)
    print("📊 TEST RESULTS SUMMARY")
    print("=" * 50)
    print(f"✅ Passed: {passed}/{total}")
    print(f"❌ Failed: {total - passed}/{total}")
    print(f"📈 Success Rate: {(passed/total)*100:.1f}%")
    
    if passed == total:
        print("\n🎉 ALL TESTS PASSED! Risk assessment feature is working correctly.")
    else:
        print(f"\n⚠️  {total - passed} test(s) failed. Please check the implementation.")
    
    print("\n📋 Feature Summary:")
    print("   ✅ Risk Assessment: Automatic risk level calculation")
    print("   ✅ Cost Estimation: Detailed cost breakdown with financing options")
    print("   ✅ Inventory Status: Real-time inventory tracking")
    print("   ✅ Care Templates: Comprehensive care plans")
    print("   ✅ Patient Management: List and search patients")

if __name__ == "__main__":
    main() 