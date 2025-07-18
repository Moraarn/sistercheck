import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import axios from 'axios';
import { Patient, IPatient } from './model';
import { PatientSignupRequest, PatientSigninRequest, PatientProfileUpdateRequest, PatientCreateWithAssessmentRequest, PatientSearchRequest, PatientResponse, PatientListResponse, PatientSignupResponse } from './type';
import { JWT_SECRET } from '../../config/env';

export class PatientService {
  private readonly JWT_SECRET = JWT_SECRET;
  private readonly JWT_EXPIRES_IN = '7d';

  // Patient signup
  async signup(data: PatientSignupRequest): Promise<PatientSignupResponse> {
    try {
      // Check if patient already exists
      const existingPatient = await Patient.findOne({ 'auth.email': data.email.toLowerCase() });
      if (existingPatient) {
        return {
          success: false,
          message: 'Patient with this email already exists',
        };
      }

      // Hash password
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(data.password, saltRounds);

      // Create patient with minimal data
      const patient = new Patient({
        auth: {
          email: data.email.toLowerCase(),
          phone: data.phone,
          password: hashedPassword,
          status: 'active',
        },
        medicalData: {
          riskLevel: 'unknown',
        },
      });

      await patient.save();

      // Generate JWT token for auto-login
      const token = jwt.sign(
        { 
          patientId: patient._id,
          email: patient.auth.email,
          type: 'patient'
        },
        this.JWT_SECRET,
        { expiresIn: this.JWT_EXPIRES_IN }
      );

      // Return patient data without password
      const patientResponse = this.formatPatientResponse(patient);

      return {
        success: true,
        message: 'Patient registered successfully',
        patient: patientResponse,
        token,
      };
    } catch (error) {
      console.error('Patient signup error:', error);
      return {
        success: false,
        message: 'Failed to register patient',
      };
    }
  }

  // Patient signin
  async signin(data: PatientSigninRequest): Promise<{ success: boolean; message: string; patient?: any; token?: string }> {
    try {
      // Find patient by email
      const patient = await Patient.findOne({ 'auth.email': data.email.toLowerCase() });
      if (!patient) {
        return {
          success: false,
          message: 'Invalid email or password',
        };
      }

      // Check password
      const isPasswordValid = await bcrypt.compare(data.password, patient.auth.password);
      if (!isPasswordValid) {
        return {
          success: false,
          message: 'Invalid email or password',
        };
      }

      // Check if patient is active
      if (patient.auth.status !== 'active') {
        return {
          success: false,
          message: 'Account is not active',
        };
      }

      // Generate JWT token
      const token = jwt.sign(
        { 
          patientId: patient._id,
          email: patient.auth.email,
          type: 'patient'
        },
        this.JWT_SECRET,
        { expiresIn: this.JWT_EXPIRES_IN }
      );

      // Return patient data and token
      const patientResponse = this.formatPatientResponse(patient);

      return {
        success: true,
        message: 'Login successful',
        patient: patientResponse,
        token,
      };
    } catch (error) {
      console.error('Patient signin error:', error);
      return {
        success: false,
        message: 'Login failed',
      };
    }
  }

  // Get patient profile
  async getPatientProfile(patientId: string): Promise<{ success: boolean; message: string; patient?: any }> {
    try {
      const patient = await Patient.findById(patientId);
      if (!patient) {
        return {
          success: false,
          message: 'Patient not found',
        };
      }

      const patientResponse = this.formatPatientResponse(patient);

      return {
        success: true,
        message: 'Profile retrieved successfully',
        patient: patientResponse,
      };
    } catch (error) {
      console.error('Get patient profile error:', error);
      return {
        success: false,
        message: 'Failed to get patient profile',
      };
    }
  }

  // Update patient profile
  async updatePatientProfile(patientId: string, data: PatientProfileUpdateRequest): Promise<{ success: boolean; message: string; patient?: any }> {
    try {
      const patient = await Patient.findById(patientId);
      if (!patient) {
        return {
          success: false,
          message: 'Patient not found',
        };
      }

      // Update medical data
      if (data.medicalData) {
        Object.assign(patient.medicalData, data.medicalData);
      }

      await patient.save();

      const patientResponse = this.formatPatientResponse(patient);

      return {
        success: true,
        message: 'Profile updated successfully',
        patient: patientResponse,
      };
    } catch (error) {
      console.error('Update patient profile error:', error);
      return {
        success: false,
        message: 'Failed to update profile',
      };
    }
  }

  // Get all patients (for doctors/nurses)
  async getPatients(page: number = 1, limit: number = 10): Promise<{ success: boolean; message: string; patients?: any[]; total?: number; page?: number; limit?: number }> {
    try {
      const skip = (page - 1) * limit;
      
      const [patients, total] = await Promise.all([
        Patient.find().skip(skip).limit(limit).sort({ createdAt: -1 }),
        Patient.countDocuments(),
      ]);

      const patientsResponse = patients.map(patient => this.formatPatientResponse(patient));

      return {
        success: true,
        message: 'Patients retrieved successfully',
        patients: patientsResponse,
        total,
        page,
        limit,
      };
    } catch (error) {
      console.error('Get patients error:', error);
      return {
        success: false,
        message: 'Failed to get patients',
      };
    }
  }

  // Search patients
  async searchPatients(data: PatientSearchRequest): Promise<{ success: boolean; message: string; patients?: any[] }> {
    try {
      let query: any = {};

      switch (data.type) {
        case 'id':
          query._id = data.query;
          break;
        case 'region':
          query['medicalData.region'] = { $regex: data.query, $options: 'i' };
          break;
        case 'email':
          query['auth.email'] = { $regex: data.query, $options: 'i' };
          break;
        default:
          // Search in multiple fields
          query = {
            $or: [
              { 'auth.email': { $regex: data.query, $options: 'i' } },
              { 'medicalData.region': { $regex: data.query, $options: 'i' } },
            ],
          };
      }

      const patients = await Patient.find(query).sort({ createdAt: -1 });
      const patientsResponse = patients.map(patient => this.formatPatientResponse(patient));

      return {
        success: true,
        message: 'Search completed successfully',
        patients: patientsResponse,
      };
    } catch (error) {
      console.error('Search patients error:', error);
      return {
        success: false,
        message: 'Failed to search patients',
      };
    }
  }

  // Create patient with risk assessment
  async createPatientWithAssessment(data: PatientCreateWithAssessmentRequest): Promise<{ success: boolean; message: string; patient?: any; risk_assessment?: any }> {
    try {
      // Create patient data for risk assessment
      const patientDataForAI = {
        Age: data.age,
        'Menopause Stage': data.menopauseStage || 'Pre-menopausal',
        'SI Cyst Size cm': data.cystSize || 0,
        'Cyst Growth': 0,
        'fca 125 Level': data.ca125Level || 0,
        'Ultrasound Fe': data.ultrasoundFeatures || 'Simple cyst',
        'Reported Sym': data.symptoms || 'None',
      };

      // Call Python API for risk assessment
      const pythonApiUrl = process.env.PYTHON_API_URL || 'http://localhost:5000';
      let riskAssessment = null;
      try {
        const response = await axios.post(`${pythonApiUrl}/risk-assessment`, patientDataForAI, {
          headers: {
            'Content-Type': 'application/json',
          },
        });
        riskAssessment = response.data;
      } catch (error) {
        console.error('Python API call failed:', error);
        // Continue without risk assessment if API fails
      }

      // Create patient record
      const patient = new Patient({
        auth: {
          email: `patient_${Date.now()}@sistercheck.com`, // Generate temporary email
          password: 'temp_password', // Will be updated by patient
          status: 'pending',
        },
        medicalData: {
          age: data.age,
          region: data.region,
          cystSize: data.cystSize,
          ca125Level: data.ca125Level,
          symptoms: data.symptoms,
          menopauseStage: data.menopauseStage,
          ultrasoundFeatures: data.ultrasoundFeatures,
          riskLevel: riskAssessment?.risk_level || 'unknown',
          previousRecommendation: riskAssessment?.recommendation,
        },
      });

      await patient.save();

      const patientResponse = this.formatPatientResponse(patient);

      return {
        success: true,
        message: 'Patient created with risk assessment',
        patient: patientResponse,
        risk_assessment: riskAssessment,
      };
    } catch (error) {
      console.error('Create patient with assessment error:', error);
      return {
        success: false,
        message: 'Failed to create patient',
      };
    }
  }

  // Helper method to format patient response
  private formatPatientResponse(patient: IPatient): PatientResponse {
    return {
      id: String(patient._id),
      auth: {
        email: patient.auth.email,
        phone: patient.auth.phone,
        status: patient.auth.status,
      },
      medicalData: {
        age: patient.medicalData.age,
        region: patient.medicalData.region,
        cystSize: patient.medicalData.cystSize,
        ca125Level: patient.medicalData.ca125Level,
        symptoms: patient.medicalData.symptoms,
        menopauseStage: patient.medicalData.menopauseStage,
        ultrasoundFeatures: patient.medicalData.ultrasoundFeatures,
        riskLevel: patient.medicalData.riskLevel,
        previousRecommendation: patient.medicalData.previousRecommendation,
        careTemplate: patient.medicalData.careTemplate,
      },
      createdAt: patient.createdAt.toISOString(),
      updatedAt: patient.updatedAt.toISOString(),
    };
  }
} 