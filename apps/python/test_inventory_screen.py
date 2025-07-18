#!/usr/bin/env python3
"""
Test script for inventory screen functionality
"""

import requests
import json

# Test patient data
test_patient_data = {
    'Age': 35,
    'Menopause Stage': 'Pre-menopausal',
    'SI Cyst Size cm': 6.5,
    'Cyst Growth': 0.2,
    'fca 125 Level': 45,
    'Ultrasound Fe': 'Complex cyst',
    'Reported Sym': 'Pelvic pain, bloating'
}

def test_inventory_endpoint():
    """Test the inventory status endpoint with patient data"""
    print("📦 Testing Inventory Status Endpoint...")
    
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
            
            # Show some sample items
            if inventory_status.get('available'):
                print(f"   Sample Available Item: {inventory_status['available'][0]}")
            if inventory_status.get('low_stock'):
                print(f"   Sample Low Stock Item: {inventory_status['low_stock'][0]}")
            
            return True
        else:
            print(f"❌ Inventory Status Endpoint - FAILED (Status: {response.status_code})")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Inventory Status Endpoint - ERROR: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Testing Inventory Screen Functionality")
    print("=" * 50)
    
    if test_inventory_endpoint():
        print("\n✅ Inventory screen should now work correctly!")
        print("📱 The Flutter inventory screen will display real inventory data.")
    else:
        print("\n❌ Inventory endpoint test failed.") 