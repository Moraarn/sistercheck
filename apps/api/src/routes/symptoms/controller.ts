import { catchAsyncError } from "../../utils/api.catcher";
import { ApiResponse } from "../../utils/api.response";
import { SymptomService } from "./service";

// Create a singleton instance of SymptomService
const symptomService = new SymptomService();

/**
 * Create a new symptom entry
 */
export const createSymptom = catchAsyncError(async (req, res) => {
  const symptom = await symptomService.createSymptom({
    ...req.body,
    userId: (req as any).user._id
  });
  
  return new ApiResponse(201, "Symptom entry created successfully", { symptom }).send(res);
});

/**
 * Get symptom by ID
 */
export const getSymptomById = catchAsyncError(async (req, res) => {
  const symptom = await symptomService.getSymptomById(req.params.id);

  if (!symptom) {
    return new ApiResponse(404, "Symptom not found").send(res);
  }

  // Check if user owns this symptom entry
  if (symptom.userId !== (req as any).user._id) {
    return new ApiResponse(403, "Access denied").send(res);
  }

  return new ApiResponse(200, "Symptom found", { symptom }).send(res);
});

/**
 * Get user's latest symptom entry
 */
export const getUserLatestSymptom = catchAsyncError(async (req, res) => {
  const symptom = await symptomService.getUserLatestSymptom((req as any).user._id);

  if (!symptom) {
    return new ApiResponse(404, "No symptom entry found").send(res);
  }

  return new ApiResponse(200, "Latest symptom entry found", { symptom }).send(res);
});

/**
 * Get all symptoms for current user
 */
export const getUserSymptoms = catchAsyncError(async (req, res) => {
  const data = await symptomService.getUserSymptoms((req as any).user._id, req.query);
  return new ApiResponse(200, "Symptoms retrieved successfully", data).send(res);
});

/**
 * Update a symptom entry
 */
export const updateSymptom = catchAsyncError(async (req, res) => {
  // First check if the symptom exists and belongs to the user
  const existingSymptom = await symptomService.getSymptomById(req.params.id);
  
  if (!existingSymptom) {
    return new ApiResponse(404, "Symptom not found").send(res);
  }

  if (existingSymptom.userId !== (req as any).user._id) {
    return new ApiResponse(403, "Access denied").send(res);
  }

  const symptom = await symptomService.updateSymptom(req.params.id, req.body);
  return new ApiResponse(200, "Symptom updated successfully", { symptom }).send(res);
});

/**
 * Delete a symptom entry
 */
export const deleteSymptom = catchAsyncError(async (req, res) => {
  // First check if the symptom exists and belongs to the user
  const existingSymptom = await symptomService.getSymptomById(req.params.id);
  
  if (!existingSymptom) {
    return new ApiResponse(404, "Symptom not found").send(res);
  }

  if (existingSymptom.userId !== (req as any).user._id) {
    return new ApiResponse(403, "Access denied").send(res);
  }

  const result = await symptomService.deleteSymptom(req.params.id);
  return new ApiResponse(200, result.message).send(res);
});

/**
 * Get symptom statistics for current user
 */
export const getSymptomStats = catchAsyncError(async (req, res) => {
  const stats = await symptomService.getSymptomStats((req as any).user._id);
  return new ApiResponse(200, "Symptom statistics retrieved successfully", { stats }).send(res);
});

/**
 * Get symptoms by severity level
 */
export const getSymptomsBySeverity = catchAsyncError(async (req, res) => {
  const severity = req.params.severity as "Mild" | "Moderate" | "Severe";
  
  if (!["Mild", "Moderate", "Severe"].includes(severity)) {
    return new ApiResponse(400, "Invalid severity level").send(res);
  }

  const symptoms = await symptomService.getSymptomsBySeverity((req as any).user._id, severity);
  return new ApiResponse(200, "Symptoms retrieved successfully", { symptoms }).send(res);
});

/**
 * Get recent symptoms (last 30 days)
 */
export const getRecentSymptoms = catchAsyncError(async (req, res) => {
  const symptoms = await symptomService.getRecentSymptoms((req as any).user._id);
  return new ApiResponse(200, "Recent symptoms retrieved successfully", { symptoms }).send(res);
}); 