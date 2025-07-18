export interface PatientSignupResponse {
  success: boolean;
  message: string;
  patient?: any;
  token?: string;
}

export interface PatientSignupRequest {
  email: string;
  password: string;
  phone?: string;
}

export interface PatientSigninRequest {
  email: string;
  password: string;
}

export interface PatientProfileUpdateRequest {
  medicalData: {
    age?: number;
    region?: string;
    cystSize?: number;
    ca125Level?: number;
    symptoms?: string;
    menopauseStage?: string;
    ultrasoundFeatures?: string;
    riskLevel?: 'low' | 'medium' | 'high' | 'unknown';
    previousRecommendation?: string;
    careTemplate?: any;
  };
}

export interface PatientCreateWithAssessmentRequest {
  age: number;
  region: string;
  cystSize?: number;
  ca125Level?: number;
  symptoms?: string;
  menopauseStage?: string;
  ultrasoundFeatures?: string;
}

export interface PatientSearchRequest {
  query: string;
  type: 'id' | 'region' | 'email';
}

export interface PatientResponse {
  id: string;
  auth: {
    email: string;
    phone?: string;
    status: string;
  };
  medicalData: {
    age?: number;
    region?: string;
    cystSize?: number;
    ca125Level?: number;
    symptoms?: string;
    menopauseStage?: string;
    ultrasoundFeatures?: string;
    riskLevel: string;
    previousRecommendation?: string;
    careTemplate?: any;
  };
  createdAt: string;
  updatedAt: string;
}

export interface PatientListResponse {
  patients: PatientResponse[];
  total: number;
  page: number;
  limit: number;
} 