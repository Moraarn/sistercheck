"""
Simplified Integration Modules for Ovarian Cyst Prediction System
Compatible with Python 3.13 and minimal dependencies
"""

import json
import requests
from datetime import datetime
from typing import Dict, List, Optional, Any
import uuid

class SimpleFHIRIntegration:
    """Simplified FHIR integration using standard libraries"""
    
    def __init__(self, fhir_base_url: str = "http://hapi.fhir.org/baseR4"):
        self.fhir_base_url = fhir_base_url
        self.headers = {
            'Content-Type': 'application/fhir+json',
            'Accept': 'application/fhir+json'
        }
    
    def create_patient_resource(self, patient_data: Dict) -> Dict:
        """Create simplified FHIR Patient resource"""
        patient_id = patient_data.get('patient_id', str(uuid.uuid4()))
        
        fhir_patient = {
            "resourceType": "Patient",
            "id": patient_id,
            "identifier": [
                {
                    "system": "http://hospital.example.com/patients",
                    "value": patient_id
                }
            ],
            "active": True,
            "name": [
                {
                    "use": "official",
                    "text": f"Patient {patient_id}"
                }
            ],
            "gender": "female",
            "birthDate": self._calculate_birth_date(patient_data.get('age', 0)),
            "address": [
                {
                    "use": "home",
                    "text": patient_data.get('region', 'Unknown'),
                    "city": patient_data.get('region', 'Unknown'),
                    "country": "KE"
                }
            ]
        }
        
        return fhir_patient
    
    def create_observation_resource(self, patient_data: Dict, observation_type: str) -> Dict:
        """Create simplified FHIR Observation resource"""
        observation_id = str(uuid.uuid4())
        
        observation = {
            "resourceType": "Observation",
            "id": observation_id,
            "status": "final",
            "code": {
                "coding": [
                    {
                        "system": "http://loinc.org",
                        "code": "LP29708-2",
                        "display": observation_type.replace('_', ' ').title()
                    }
                ]
            },
            "subject": {
                "reference": f"Patient/{patient_data.get('patient_id', 'unknown')}"
            },
            "effectiveDateTime": datetime.now().isoformat(),
            "valueQuantity": {
                "value": self._get_observation_value(patient_data, observation_type),
                "unit": self._get_observation_unit(observation_type)
            }
        }
        
        return observation
    
    def send_to_fhir_server(self, resource: Dict, resource_type: str) -> Dict:
        """Send FHIR resource to server"""
        try:
            url = f"{self.fhir_base_url}/{resource_type}"
            response = requests.post(url, json=resource, headers=self.headers)
            
            if response.status_code in [200, 201]:
                return {
                    "success": True,
                    "fhir_id": response.json().get('id'),
                    "resource_type": resource_type,
                    "message": "Resource created successfully"
                }
            else:
                return {
                    "success": False,
                    "error": f"Failed to create {resource_type}",
                    "status_code": response.status_code
                }
        except Exception as e:
            return {
                "success": False,
                "error": f"Exception while sending to FHIR server: {str(e)}"
            }
    
    def _calculate_birth_date(self, age: int) -> str:
        """Calculate birth date from age"""
        current_year = datetime.now().year
        birth_year = current_year - age
        return f"{birth_year}-01-01"
    
    def _get_observation_value(self, patient_data: Dict, observation_type: str) -> float:
        """Get observation value from patient data"""
        value_mapping = {
            'cyst_size': patient_data.get('cyst_size', 0),
            'ca125': patient_data.get('ca125_level', 0),
            'age': patient_data.get('age', 0)
        }
        return value_mapping.get(observation_type, 0)
    
    def _get_observation_unit(self, observation_type: str) -> str:
        """Get observation unit"""
        unit_mapping = {
            'cyst_size': 'cm',
            'ca125': 'U/mL',
            'age': 'years'
        }
        return unit_mapping.get(observation_type, 'unknown')

class SimpleHIEIntegration:
    """Simplified OpenHIE integration"""
    
    def __init__(self, hie_base_url: str = "http://localhost:8080/openhim-core"):
        self.hie_base_url = hie_base_url
        self.headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    
    def create_patient_registry_message(self, patient_data: Dict) -> Dict:
        """Create simplified OpenHIE Patient Registry message"""
        message_id = str(uuid.uuid4())
        
        hie_message = {
            "messageId": message_id,
            "messageType": "PRPA_IN201301UV02",
            "creationTime": datetime.now().isoformat(),
            "patient": {
                "id": patient_data.get('patient_id', 'unknown'),
                "age": patient_data.get('age', 0),
                "region": patient_data.get('region', 'Unknown'),
                "gender": "female"
            }
        }
        
        return hie_message
    
    def create_facility_registry_message(self, facility_data: Dict) -> Dict:
        """Create simplified OpenHIE Facility Registry message"""
        message_id = str(uuid.uuid4())
        
        hie_message = {
            "messageId": message_id,
            "messageType": "PRPA_IN201301UV02",
            "creationTime": datetime.now().isoformat(),
            "facility": {
                "id": facility_data.get('facility_id', 'unknown'),
                "name": facility_data.get('facility_name', 'Unknown Facility'),
                "type": facility_data.get('facility_type', 'Hospital'),
                "region": facility_data.get('region', 'Unknown')
            }
        }
        
        return hie_message
    
    def send_to_hie(self, message: Dict, endpoint: str) -> Dict:
        """Send message to OpenHIE endpoint"""
        try:
            url = f"{self.hie_base_url}/{endpoint}"
            response = requests.post(url, json=message, headers=self.headers)
            
            if response.status_code in [200, 201, 202]:
                return {
                    "success": True,
                    "message_id": message.get('messageId'),
                    "endpoint": endpoint
                }
            else:
                return {
                    "success": False,
                    "error": f"Failed to send to {endpoint}",
                    "status_code": response.status_code
                }
        except Exception as e:
            return {
                "success": False,
                "error": f"Exception while sending to HIE: {str(e)}"
            }

class SimpleDHIS2Integration:
    """Simplified DHIS2 integration"""
    
    def __init__(self, dhis2_base_url: str = "http://localhost:8080/dhis", 
                 username: str = "admin", password: str = "district"):
        self.dhis2_base_url = dhis2_base_url
        self.username = username
        self.password = password
        self.auth = (username, password)
        self.headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    
    def create_tracked_entity_instance(self, patient_data: Dict) -> Dict:
        """Create simplified DHIS2 Tracked Entity Instance"""
        tracked_entity_id = str(uuid.uuid4())
        
        tracked_entity = {
            "trackedEntityType": "patient",
            "orgUnit": patient_data.get('facility_id', 'default_org_unit'),
            "trackedEntityInstance": tracked_entity_id,
            "attributes": [
                {
                    "attribute": "patient_id",
                    "value": patient_data.get('patient_id', 'unknown')
                },
                {
                    "attribute": "age",
                    "value": str(patient_data.get('age', 0))
                },
                {
                    "attribute": "region",
                    "value": patient_data.get('region', 'Unknown')
                }
            ]
        }
        
        return tracked_entity
    
    def create_data_value_set(self, patient_data: Dict, prediction_result: Dict, 
                             care_template: Dict) -> Dict:
        """Create simplified DHIS2 Data Value Set"""
        data_set_id = "ovarian_cyst_dataset"
        org_unit_id = patient_data.get('facility_id', 'default_org_unit')
        period = datetime.now().strftime("%Y%m%d")
        
        data_value_set = {
            "dataSet": data_set_id,
            "completeDate": datetime.now().strftime("%Y-%m-%d"),
            "period": period,
            "orgUnit": org_unit_id,
            "dataValues": [
                {
                    "dataElement": "cyst_size",
                    "categoryOptionCombo": "default",
                    "value": str(patient_data.get('cyst_size', 0))
                },
                {
                    "dataElement": "ca125_level",
                    "categoryOptionCombo": "default",
                    "value": str(patient_data.get('ca125_level', 0))
                },
                {
                    "dataElement": "prediction_result",
                    "categoryOptionCombo": "default",
                    "value": prediction_result.get('prediction', 'Unknown')
                }
            ]
        }
        
        return data_value_set
    
    def send_to_dhis2(self, data: Dict, endpoint: str) -> Dict:
        """Send data to DHIS2 endpoint"""
        try:
            url = f"{self.dhis2_base_url}/api/{endpoint}"
            response = requests.post(url, json=data, headers=self.headers, auth=self.auth)
            
            if response.status_code in [200, 201, 202]:
                return {
                    "success": True,
                    "endpoint": endpoint
                }
            else:
                return {
                    "success": False,
                    "error": f"Failed to send to DHIS2 {endpoint}",
                    "status_code": response.status_code
                }
        except Exception as e:
            return {
                "success": False,
                "error": f"Exception while sending to DHIS2: {str(e)}"
            } 