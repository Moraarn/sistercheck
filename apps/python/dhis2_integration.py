"""
DHIS2 Integration Module for Ovarian Cyst Prediction System
Supports DHIS2 (District Health Information Software 2) for health management information system integration
"""

import json
import requests
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
import uuid

class DHIS2Integration:
    """DHIS2 integration for health management information system"""
    
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
        """Create DHIS2 Tracked Entity Instance for patient"""
        tracked_entity_id = str(uuid.uuid4())
        
        # DHIS2 Tracked Entity Instance for patient
        tracked_entity = {
            "trackedEntityType": "patient",  # This should be configured in DHIS2
            "orgUnit": patient_data.get('facility_id', 'default_org_unit'),
            "trackedEntityInstance": tracked_entity_id,
            "attributes": [
                {
                    "attribute": "patient_id",
                    "value": patient_data.get('patient_id', 'unknown')
                },
                {
                    "attribute": "patient_name",
                    "value": f"Patient {patient_data.get('patient_id', 'unknown')}"
                },
                {
                    "attribute": "age",
                    "value": str(patient_data.get('age', 0))
                },
                {
                    "attribute": "gender",
                    "value": "Female"
                },
                {
                    "attribute": "region",
                    "value": patient_data.get('region', 'Unknown')
                },
                {
                    "attribute": "facility",
                    "value": patient_data.get('facility_name', 'Unknown Facility')
                }
            ]
        }
        
        return tracked_entity
    
    def create_data_value_set(self, patient_data: Dict, prediction_result: Dict, 
                             care_template: Dict) -> Dict:
        """Create DHIS2 Data Value Set for ovarian cyst data"""
        data_set_id = "ovarian_cyst_dataset"  # This should be configured in DHIS2
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
                    "dataElement": "patient_age",
                    "categoryOptionCombo": "default",
                    "value": str(patient_data.get('age', 0))
                },
                {
                    "dataElement": "prediction_result",
                    "categoryOptionCombo": "default",
                    "value": prediction_result.get('prediction', 'Unknown')
                },
                {
                    "dataElement": "risk_level",
                    "categoryOptionCombo": "default",
                    "value": care_template.get('patient_summary', {}).get('risk_level', 'Unknown')
                },
                {
                    "dataElement": "treatment_plan",
                    "categoryOptionCombo": "default",
                    "value": care_template.get('ai_recommendation', {}).get('treatment_plan', 'Unknown')
                },
                {
                    "dataElement": "confidence_score",
                    "categoryOptionCombo": "default",
                    "value": str(care_template.get('ai_recommendation', {}).get('confidence', 0))
                }
            ]
        }
        
        return data_value_set
    
    def create_event(self, patient_data: Dict, event_type: str, event_data: Dict) -> Dict:
        """Create DHIS2 Event for specific clinical events"""
        event_id = str(uuid.uuid4())
        program_id = "ovarian_cyst_program"  # This should be configured in DHIS2
        org_unit_id = patient_data.get('facility_id', 'default_org_unit')
        
        event = {
            "event": event_id,
            "program": program_id,
            "programStage": event_type,
            "orgUnit": org_unit_id,
            "eventDate": datetime.now().strftime("%Y-%m-%d"),
            "status": "COMPLETED",
            "trackedEntityInstance": patient_data.get('patient_id', 'unknown'),
            "dataValues": []
        }
        
        # Add event-specific data values
        if event_type == "initial_assessment":
            event["dataValues"] = [
                {
                    "dataElement": "cyst_size_initial",
                    "value": str(patient_data.get('cyst_size', 0))
                },
                {
                    "dataElement": "ca125_initial",
                    "value": str(patient_data.get('ca125_level', 0))
                },
                {
                    "dataElement": "symptoms_present",
                    "value": "Yes" if patient_data.get('symptoms', []) else "No"
                }
            ]
        elif event_type == "treatment_plan":
            event["dataValues"] = [
                {
                    "dataElement": "recommended_treatment",
                    "value": event_data.get('treatment_plan', 'Unknown')
                },
                {
                    "dataElement": "risk_assessment",
                    "value": event_data.get('risk_level', 'Unknown')
                },
                {
                    "dataElement": "ai_confidence",
                    "value": str(event_data.get('confidence', 0))
                }
            ]
        elif event_type == "follow_up":
            event["dataValues"] = [
                {
                    "dataElement": "cyst_size_followup",
                    "value": str(event_data.get('cyst_size', 0))
                },
                {
                    "dataElement": "treatment_effectiveness",
                    "value": event_data.get('effectiveness', 'Unknown')
                },
                {
                    "dataElement": "patient_compliance",
                    "value": event_data.get('compliance', 'Unknown')
                }
            ]
        
        return event
    
    def create_analytics_data(self, facility_data: Dict, time_period: str = "monthly") -> Dict:
        """Create DHIS2 Analytics data for reporting"""
        analytics_data = {
            "dx": [
                "cyst_size",  # Data element for cyst size
                "ca125_level",  # Data element for CA-125
                "prediction_result",  # Data element for prediction
                "risk_level"  # Data element for risk level
            ],
            "ou": [facility_data.get('facility_id', 'default_org_unit')],
            "pe": time_period,
            "displayProperty": "NAME",
            "outputType": "EVENT"
        }
        
        return analytics_data
    
    def send_to_dhis2(self, data: Dict, endpoint: str) -> Dict:
        """Send data to DHIS2 endpoint"""
        try:
            url = f"{self.dhis2_base_url}/api/{endpoint}"
            response = requests.post(url, json=data, headers=self.headers, auth=self.auth)
            
            if response.status_code in [200, 201, 202]:
                return {
                    "success": True,
                    "endpoint": endpoint,
                    "response": response.json() if response.content else None
                }
            else:
                return {
                    "success": False,
                    "error": f"Failed to send to DHIS2 {endpoint}",
                    "status_code": response.status_code,
                    "response": response.text
                }
        except Exception as e:
            return {
                "success": False,
                "error": f"Exception while sending to DHIS2: {str(e)}"
            }
    
    def get_analytics_report(self, analytics_data: Dict) -> Dict:
        """Get analytics report from DHIS2"""
        try:
            url = f"{self.dhis2_base_url}/api/analytics"
            response = requests.get(url, params=analytics_data, headers=self.headers, auth=self.auth)
            
            if response.status_code == 200:
                return {
                    "success": True,
                    "analytics_data": response.json()
                }
            else:
                return {
                    "success": False,
                    "error": f"Failed to get analytics report",
                    "status_code": response.status_code,
                    "response": response.text
                }
        except Exception as e:
            return {
                "success": False,
                "error": f"Exception while getting analytics: {str(e)}"
            }
    
    def create_org_unit(self, facility_data: Dict) -> Dict:
        """Create DHIS2 Organisation Unit for facility"""
        org_unit = {
            "name": facility_data.get('facility_name', 'Unknown Facility'),
            "shortName": facility_data.get('facility_name', 'Unknown')[:50],
            "openingDate": datetime.now().strftime("%Y-%m-%d"),
            "organisationUnits": [],
            "attributeValues": [
                {
                    "attribute": "facility_type",
                    "value": facility_data.get('facility_type', 'Hospital')
                },
                {
                    "attribute": "region",
                    "value": facility_data.get('region', 'Unknown')
                },
                {
                    "attribute": "contact_phone",
                    "value": facility_data.get('phone', 'Unknown')
                }
            ]
        }
        
        return org_unit
    
    def create_data_element(self, element_data: Dict) -> Dict:
        """Create DHIS2 Data Element for custom data collection"""
        data_element = {
            "name": element_data.get('name', 'Unknown Element'),
            "shortName": element_data.get('short_name', 'Unknown')[:50],
            "code": element_data.get('code', 'UNKNOWN'),
            "description": element_data.get('description', ''),
            "valueType": element_data.get('value_type', 'NUMBER'),
            "aggregationType": element_data.get('aggregation_type', 'SUM'),
            "zeroIsSignificant": element_data.get('zero_is_significant', False),
            "domainType": element_data.get('domain_type', 'TRACKER'),
            "categoryCombo": {
                "id": element_data.get('category_combo_id', 'default')
            }
        }
        
        return data_element 