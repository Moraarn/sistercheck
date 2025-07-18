#!/usr/bin/env python3
"""
Test script for risk assessment and cost estimation functionality
"""

import requests
import json

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

def test_risk_assessment():
    """Test the risk assessment endpoint"""
    print("Testing Risk Assessment...")
    
    try:
        response = requests.post(
            'http://127.0.0.1:5001/risk-assessment',
            json=test_patient_data,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Risk Assessment Successful!")
            print(f"Risk Level: {result['risk_assessment']['risk_level']}")
            print(f"Risk Factors: {result['risk_assessment']['risk_factors']}")
            return result
        else:
            print(f"❌ Risk Assessment Failed: {response.status_code}")
            print(response.text)
            return None
            
    except Exception as e:
        print(f"❌ Error testing risk assessment: {e}")
        return None

def test_cost_estimation():
    """Test the cost estimation endpoint"""
    print("\nTesting Cost Estimation...")
    
    try:
        response = requests.post(
            'http://127.0.0.1:5001/cost-estimation',
            json=test_patient_data,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Cost Estimation Successful!")
            print(f"Recommended Treatment: {result['recommended_treatment']}")
            print(f"Cost Estimation: {result['cost_estimation']}")
            return result
        else:
            print(f"❌ Cost Estimation Failed: {response.status_code}")
            print(response.text)
            return None
            
    except Exception as e:
        print(f"❌ Error testing cost estimation: {e}")
        return None

def test_inventory_status():
    """Test the inventory status endpoint"""
    print("\nTesting Inventory Status...")
    
    try:
        response = requests.post(
            'http://127.0.0.1:5001/inventory-status',
            json=test_patient_data,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Inventory Status Successful!")
            print(f"Recommended Treatment: {result['recommended_treatment']}")
            print(f"Available Items: {len(result['inventory_status']['available'])}")
            print(f"Low Stock Items: {len(result['inventory_status']['low_stock'])}")
            print(f"Out of Stock Items: {len(result['inventory_status']['out_of_stock'])}")
            return result
        else:
            print(f"❌ Inventory Status Failed: {response.status_code}")
            print(response.text)
            return None
            
    except Exception as e:
        print(f"❌ Error testing inventory status: {e}")
        return None

def main():
    """Run all tests"""
    print("🚀 Testing Risk Assessment and Cost Estimation System")
    print("=" * 50)
    
    # Test risk assessment
    risk_result = test_risk_assessment()
    
    # Test cost estimation
    cost_result = test_cost_estimation()
    
    # Test inventory status
    inventory_result = test_inventory_status()
    
    print("\n" + "=" * 50)
    print("📊 Test Summary:")
    
    if risk_result:
        print("✅ Risk Assessment: PASSED")
    else:
        print("❌ Risk Assessment: FAILED")
        
    if cost_result:
        print("✅ Cost Estimation: PASSED")
    else:
        print("❌ Cost Estimation: FAILED")
        
    if inventory_result:
        print("✅ Inventory Status: PASSED")
    else:
        print("❌ Inventory Status: FAILED")
    
    print("\n🎉 Testing Complete!")

if __name__ == "__main__":
    main() 