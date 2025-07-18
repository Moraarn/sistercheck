import { Request, Response } from 'express';
import { catchAsyncError } from '../../utils/api.catcher';
import { ApiResponse } from '../../utils/api.response';
import { PatientService } from './service';
import { PatientSignupRequest, PatientSigninRequest, PatientProfileUpdateRequest, PatientCreateWithAssessmentRequest, PatientSearchRequest } from './type';

// Create a singleton instance of PatientService
const patientService = new PatientService();

/**
 * Patient signup
 */
export const signup = catchAsyncError(async (req: Request, res: Response) => {
  const data: PatientSignupRequest = req.body;

  // Validate required fields
  if (!data.email || !data.password) {
    return new ApiResponse(400, 'Email and password are required').send(res);
  }

  const result = await patientService.signup(data);

  if (result.success) {
    return new ApiResponse(201, result.message, { patient: result.patient, token: result.token }).send(res);
  } else {
    return new ApiResponse(400, result.message).send(res);
  }
});

/**
 * Patient signin
 */
export const signin = catchAsyncError(async (req: Request, res: Response) => {
  const data: PatientSigninRequest = req.body;

  // Validate required fields
  if (!data.email || !data.password) {
    return new ApiResponse(400, 'Email and password are required').send(res);
  }

  const result = await patientService.signin(data);

  if (result.success) {
    return new ApiResponse(200, result.message, { patient: result.patient, token: result.token }).send(res);
  } else {
    return new ApiResponse(401, result.message).send(res);
  }
});

/**
 * Get patient profile
 */
export const getProfile = catchAsyncError(async (req: Request, res: Response) => {
  const patientId = (req as any).user?.patientId;
  if (!patientId) {
    return new ApiResponse(401, 'Authentication required').send(res);
  }

  const result = await patientService.getPatientProfile(patientId);

  if (result.success) {
    return new ApiResponse(200, 'Profile retrieved successfully', { patient: result.patient }).send(res);
  } else {
    return new ApiResponse(404, result.message).send(res);
  }
});

/**
 * Update patient profile
 */
export const updateProfile = catchAsyncError(async (req: Request, res: Response) => {
  const patientId = (req as any).user?.patientId;
  if (!patientId) {
    return new ApiResponse(401, 'Authentication required').send(res);
  }

  const data: PatientProfileUpdateRequest = req.body;
  const result = await patientService.updatePatientProfile(patientId, data);

  if (result.success) {
    return new ApiResponse(200, result.message, { patient: result.patient }).send(res);
  } else {
    return new ApiResponse(400, result.message).send(res);
  }
});

/**
 * Get all patients (for doctors/nurses)
 */
export const getPatients = catchAsyncError(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;

  const result = await patientService.getPatients(page, limit);

  if (result.success) {
    return new ApiResponse(200, 'Patients retrieved successfully', {
      patients: result.patients,
      total: result.total,
      page: result.page,
      limit: result.limit,
    }).send(res);
  } else {
    return new ApiResponse(400, result.message).send(res);
  }
});

/**
 * Search patients
 */
export const searchPatients = catchAsyncError(async (req: Request, res: Response) => {
  const data: PatientSearchRequest = {
    query: req.query.query as string,
    type: (req.query.type as 'id' | 'region' | 'email') || 'region',
  };

  if (!data.query) {
    return new ApiResponse(400, 'Search query is required').send(res);
  }

  const result = await patientService.searchPatients(data);

  if (result.success) {
    return new ApiResponse(200, 'Search completed successfully', { patients: result.patients }).send(res);
  } else {
    return new ApiResponse(400, result.message).send(res);
  }
});

/**
 * Create patient with risk assessment
 */
export const createPatientWithAssessment = catchAsyncError(async (req: Request, res: Response) => {
  const data: PatientCreateWithAssessmentRequest = req.body;

  // Validate required fields
  if (!data.age || !data.region) {
    return new ApiResponse(400, 'Age and region are required').send(res);
  }

  const result = await patientService.createPatientWithAssessment(data);

  if (result.success) {
    return new ApiResponse(201, result.message, {
      patient: result.patient,
      risk_assessment: result.risk_assessment,
    }).send(res);
  } else {
    return new ApiResponse(400, result.message).send(res);
  }
});

/**
 * Patient logout
 */
export const logout = catchAsyncError(async (req: Request, res: Response) => {
  // In a real implementation, you might want to blacklist the token
  return new ApiResponse(200, 'Logged out successfully').send(res);
}); 