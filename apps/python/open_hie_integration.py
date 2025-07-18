"""
OpenHIE Integration Module for Ovarian Cyst Prediction System
Supports Open Health Information Exchange (OpenHIE) for national health system integration
"""

import json
import requests
from datetime import datetime
from typing import Dict, List, Optional, Any
import uuid

class OpenHIEIntegration:
    """OpenHIE integration for health information exchange"""
    
    def __init__(self, hie_base_url: str = "http://localhost:8080/openhim-core"):
        self.hie_base_url = hie_base_url
        self.headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    
    def create_patient_registry_message(self, patient_data: Dict) -> Dict:
        """Create OpenHIE Patient Registry message"""
        message_id = str(uuid.uuid4())
        
        # OpenHIE Patient Registry message format
        patient_registry_message = {
            "messageId": message_id,
            "messageType": "PRPA_IN201301UV02",
            "creationTime": datetime.now().isoformat(),
            "versionCode": "2013",
            "interactionId": "PRPA_IN201301UV02",
            "processingCode": "P",
            "processingModeCode": "T",
            "acceptAckCode": "AL",
            "receiver": {
                "device": {
                    "id": {
                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                        "extension": "HIE_PATIENT_REGISTRY"
                    }
                }
            },
            "sender": {
                "device": {
                    "id": {
                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                        "extension": "OVARIAN_CYST_SYSTEM"
                    }
                }
            },
            "controlActProcess": {
                "classCode": "CACT",
                "moodCode": "EVN",
                "subject": {
                    "registrationEvent": {
                        "id": {
                            "root": "2.16.840.1.113883.3.72.6.5.100.1",
                            "extension": patient_data.get('patient_id', 'unknown')
                        },
                        "statusCode": {
                            "code": "active"
                        },
                        "subject1": {
                            "patient": {
                                "id": [
                                    {
                                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                                        "extension": patient_data.get('patient_id', 'unknown')
                                    }
                                ],
                                "statusCode": {
                                    "code": "active"
                                },
                                "patientPerson": {
                                    "name": [
                                        {
                                            "given": ["Patient"],
                                            "family": [patient_data.get('patient_id', 'unknown')]
                                        }
                                    ],
                                    "administrativeGenderCode": {
                                        "code": "F",
                                        "codeSystem": "2.16.840.1.113883.5.1"
                                    },
                                    "birthTime": {
                                        "value": self._calculate_birth_date(patient_data.get('age', 0))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return patient_registry_message
    
    def create_health_worker_registry_message(self, health_worker_data: Dict) -> Dict:
        """Create OpenHIE Health Worker Registry message"""
        message_id = str(uuid.uuid4())
        
        health_worker_message = {
            "messageId": message_id,
            "messageType": "PRPA_IN201301UV02",
            "creationTime": datetime.now().isoformat(),
            "versionCode": "2013",
            "interactionId": "PRPA_IN201301UV02",
            "processingCode": "P",
            "processingModeCode": "T",
            "acceptAckCode": "AL",
            "receiver": {
                "device": {
                    "id": {
                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                        "extension": "HIE_HEALTH_WORKER_REGISTRY"
                    }
                }
            },
            "sender": {
                "device": {
                    "id": {
                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                        "extension": "OVARIAN_CYST_SYSTEM"
                    }
                }
            },
            "controlActProcess": {
                "classCode": "CACT",
                "moodCode": "EVN",
                "subject": {
                    "registrationEvent": {
                        "id": {
                            "root": "2.16.840.1.113883.3.72.6.5.100.1",
                            "extension": health_worker_data.get('worker_id', 'unknown')
                        },
                        "statusCode": {
                            "code": "active"
                        },
                        "subject1": {
                            "healthCareProvider": {
                                "id": [
                                    {
                                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                                        "extension": health_worker_data.get('worker_id', 'unknown')
                                    }
                                ],
                                "statusCode": {
                                    "code": "active"
                                },
                                "healthCareProviderPerson": {
                                    "name": [
                                        {
                                            "given": [health_worker_data.get('first_name', 'Unknown')],
                                            "family": [health_worker_data.get('last_name', 'Unknown')]
                                        }
                                    ],
                                    "administrativeGenderCode": {
                                        "code": health_worker_data.get('gender', 'U'),
                                        "codeSystem": "2.16.840.1.113883.5.1"
                                    }
                                },
                                "asOrganizationPartOf": {
                                    "wholeOrganization": {
                                        "id": [
                                            {
                                                "root": "2.16.840.1.113883.3.72.6.5.100.1",
                                                "extension": health_worker_data.get('facility_id', 'unknown')
                                            }
                                        ],
                                        "name": health_worker_data.get('facility_name', 'Unknown Facility')
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return health_worker_message
    
    def create_facility_registry_message(self, facility_data: Dict) -> Dict:
        """Create OpenHIE Facility Registry message"""
        message_id = str(uuid.uuid4())
        
        facility_message = {
            "messageId": message_id,
            "messageType": "PRPA_IN201301UV02",
            "creationTime": datetime.now().isoformat(),
            "versionCode": "2013",
            "interactionId": "PRPA_IN201301UV02",
            "processingCode": "P",
            "processingModeCode": "T",
            "acceptAckCode": "AL",
            "receiver": {
                "device": {
                    "id": {
                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                        "extension": "HIE_FACILITY_REGISTRY"
                    }
                }
            },
            "sender": {
                "device": {
                    "id": {
                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                        "extension": "OVARIAN_CYST_SYSTEM"
                    }
                }
            },
            "controlActProcess": {
                "classCode": "CACT",
                "moodCode": "EVN",
                "subject": {
                    "registrationEvent": {
                        "id": {
                            "root": "2.16.840.1.113883.3.72.6.5.100.1",
                            "extension": facility_data.get('facility_id', 'unknown')
                        },
                        "statusCode": {
                            "code": "active"
                        },
                        "subject1": {
                            "organization": {
                                "id": [
                                    {
                                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                                        "extension": facility_data.get('facility_id', 'unknown')
                                    }
                                ],
                                "statusCode": {
                                    "code": "active"
                                },
                                "name": facility_data.get('facility_name', 'Unknown Facility'),
                                "addr": [
                                    {
                                        "streetAddressLine": [facility_data.get('address', 'Unknown')],
                                        "city": facility_data.get('city', 'Unknown'),
                                        "state": facility_data.get('state', 'Unknown'),
                                        "country": "KE"
                                    }
                                ],
                                "telecom": [
                                    {
                                        "value": facility_data.get('phone', 'Unknown'),
                                        "use": "WP"
                                    }
                                ]
                            }
                        }
                    }
                }
            }
        }
        
        return facility_message
    
    def create_shared_health_record_message(self, patient_data: Dict, care_template: Dict) -> Dict:
        """Create OpenHIE Shared Health Record message"""
        message_id = str(uuid.uuid4())
        
        # Create clinical document
        clinical_document = {
            "messageId": message_id,
            "messageType": "PRPA_IN201301UV02",
            "creationTime": datetime.now().isoformat(),
            "versionCode": "2013",
            "interactionId": "PRPA_IN201301UV02",
            "processingCode": "P",
            "processingModeCode": "T",
            "acceptAckCode": "AL",
            "receiver": {
                "device": {
                    "id": {
                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                        "extension": "HIE_SHARED_HEALTH_RECORD"
                    }
                }
            },
            "sender": {
                "device": {
                    "id": {
                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                        "extension": "OVARIAN_CYST_SYSTEM"
                    }
                }
            },
            "controlActProcess": {
                "classCode": "CACT",
                "moodCode": "EVN",
                "subject": {
                    "clinicalDocument": {
                        "id": {
                            "root": "2.16.840.1.113883.3.72.6.5.100.1",
                            "extension": f"DOC_{patient_data.get('patient_id', 'unknown')}_{datetime.now().strftime('%Y%m%d%H%M%S')}"
                        },
                        "code": {
                            "code": "11506-3",
                            "codeSystem": "2.16.840.1.113883.6.1",
                            "displayName": "Progress note"
                        },
                        "title": f"Ovarian Cyst Care Plan - {patient_data.get('patient_id', 'Unknown')}",
                        "effectiveTime": {
                            "value": datetime.now().isoformat()
                        },
                        "confidentialityCode": {
                            "code": "N",
                            "codeSystem": "2.16.840.1.113883.5.25"
                        },
                        "languageCode": {
                            "code": "en-US"
                        },
                        "setId": {
                            "root": "2.16.840.1.113883.3.72.6.5.100.1",
                            "extension": "1"
                        },
                        "versionNumber": {
                            "value": "1"
                        },
                        "recordTarget": {
                            "patientRole": {
                                "id": [
                                    {
                                        "root": "2.16.840.1.113883.3.72.6.5.100.1",
                                        "extension": patient_data.get('patient_id', 'unknown')
                                    }
                                ]
                            }
                        },
                        "author": {
                            "assignedAuthor": {
                                "id": {
                                    "root": "2.16.840.1.113883.3.72.6.5.100.1",
                                    "extension": "AI_SYSTEM"
                                },
                                "assignedPerson": {
                                    "name": {
                                        "given": ["AI"],
                                        "family": ["System"]
                                    }
                                }
                            }
                        },
                        "component": {
                            "structuredBody": {
                                "component": [
                                    {
                                        "section": {
                                            "code": {
                                                "code": "8716-3",
                                                "codeSystem": "2.16.840.1.113883.6.1",
                                                "displayName": "Vital signs"
                                            },
                                            "title": "Patient Assessment",
                                            "text": {
                                                "content": f"Age: {patient_data.get('age', 'Unknown')}\nCyst Size: {patient_data.get('cyst_size', 'Unknown')} cm\nCA-125 Level: {patient_data.get('ca125_level', 'Unknown')} U/mL"
                                            }
                                        }
                                    },
                                    {
                                        "section": {
                                            "code": {
                                                "code": "18776-5",
                                                "codeSystem": "2.16.840.1.113883.6.1",
                                                "displayName": "Plan of care"
                                            },
                                            "title": "Treatment Plan",
                                            "text": {
                                                "content": f"AI Recommendation: {care_template.get('ai_recommendation', {}).get('treatment_plan', 'Unknown')}\nConfidence: {care_template.get('ai_recommendation', {}).get('confidence', 'Unknown')}\nRisk Level: {care_template.get('patient_summary', {}).get('risk_level', 'Unknown')}"
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    }
                }
            }
        }
        
        return clinical_document
    
    def send_to_hie(self, message: Dict, endpoint: str) -> Dict:
        """Send message to OpenHIE endpoint"""
        try:
            url = f"{self.hie_base_url}/{endpoint}"
            response = requests.post(url, json=message, headers=self.headers)
            
            if response.status_code in [200, 201, 202]:
                return {
                    "success": True,
                    "message_id": message.get('messageId'),
                    "endpoint": endpoint,
                    "response": response.json() if response.content else None
                }
            else:
                return {
                    "success": False,
                    "error": f"Failed to send to {endpoint}",
                    "status_code": response.status_code,
                    "response": response.text
                }
        except Exception as e:
            return {
                "success": False,
                "error": f"Exception while sending to HIE: {str(e)}"
            }
    
    def _calculate_birth_date(self, age: int) -> str:
        """Calculate birth date from age"""
        current_year = datetime.now().year
        birth_year = current_year - age
        return f"{birth_year}0101"  # HL7 date format 