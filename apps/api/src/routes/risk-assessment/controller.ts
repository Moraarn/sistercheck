import { catchAsyncError } from "../../utils/api.catcher";
import { ApiResponse } from "../../utils/api.response";
import { RiskAssessmentService } from "./service";

// Create a singleton instance of RiskAssessmentService
const riskAssessmentService = new RiskAssessmentService();

/**
 * Create a new risk assessment
 */
export const createRiskAssessment = catchAsyncError(async (req, res) => {
  const assessment = await riskAssessmentService.createRiskAssessment({
    ...req.body,
    userId: (req as any).user._id
  });
  
  return new ApiResponse(201, "Risk assessment created successfully", { assessment }).send(res);
});

/**
 * Get risk assessment by ID
 */
export const getRiskAssessmentById = catchAsyncError(async (req, res) => {
  const assessment = await riskAssessmentService.getRiskAssessmentById(req.params.id);

  if (!assessment) {
    return new ApiResponse(404, "Risk assessment not found").send(res);
  }

  // Check if user owns this assessment
  if (assessment.userId !== (req as any).user._id) {
    return new ApiResponse(403, "Access denied").send(res);
  }

  return new ApiResponse(200, "Risk assessment found", { assessment }).send(res);
});

/**
 * Get user's latest risk assessment
 */
export const getUserLatestAssessment = catchAsyncError(async (req, res) => {
  const assessment = await riskAssessmentService.getUserLatestAssessment((req as any).user._id);

  if (!assessment) {
    return new ApiResponse(404, "No risk assessment found").send(res);
  }

  return new ApiResponse(200, "Latest risk assessment found", { assessment }).send(res);
});

/**
 * Get all risk assessments for current user
 */
export const getUserAssessments = catchAsyncError(async (req, res) => {
  const data = await riskAssessmentService.getUserAssessments((req as any).user._id, req.query);
  return new ApiResponse(200, "Risk assessments retrieved successfully", data).send(res);
}); 