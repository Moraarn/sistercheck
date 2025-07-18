import { catchAsyncError } from "../../utils/api.catcher";
import { ApiResponse } from "../../utils/api.response";
import { UserRequest } from "../../types/auth";
import { CareTemplateService } from "./service";

// Create a singleton instance of CareTemplateService
const careTemplateService = new CareTemplateService();

/**
 * Create a new care template with AI prediction
 */
export const createCareTemplate = catchAsyncError<UserRequest>(async (req, res) => {
  const careTemplate = await careTemplateService.createCareTemplate({
    ...req.body,
    userId: req.user._id
  });
  
  return new ApiResponse(201, "Care template created successfully", { careTemplate }).send(res);
});

/**
 * Get care template by ID
 */
export const getCareTemplateById = catchAsyncError<UserRequest>(async (req, res) => {
  const careTemplate = await careTemplateService.getCareTemplateById(req.params.id);

  if (!careTemplate) {
    return new ApiResponse(404, "Care template not found").send(res);
  }

  // Check if user owns this care template
  if (careTemplate.userId !== req.user._id) {
    return new ApiResponse(403, "Access denied").send(res);
  }

  return new ApiResponse(200, "Care template found", { careTemplate }).send(res);
});

/**
 * Get user's latest care template
 */
export const getUserLatestCareTemplate = catchAsyncError<UserRequest>(async (req, res) => {
  const careTemplate = await careTemplateService.getUserLatestCareTemplate(req.user._id);

  if (!careTemplate) {
    return new ApiResponse(404, "No care template found").send(res);
  }

  return new ApiResponse(200, "Latest care template found", { careTemplate }).send(res);
});

/**
 * Get all care templates for current user
 */
export const getUserCareTemplates = catchAsyncError<UserRequest>(async (req, res) => {
  const data = await careTemplateService.getUserCareTemplates(req.user._id, req.query);
  return new ApiResponse(200, "Care templates retrieved successfully", data).send(res);
});

/**
 * Update a care template
 */
export const updateCareTemplate = catchAsyncError<UserRequest>(async (req, res) => {
  // First check if the care template exists and belongs to the user
  const existingTemplate = await careTemplateService.getCareTemplateById(req.params.id);
  
  if (!existingTemplate) {
    return new ApiResponse(404, "Care template not found").send(res);
  }

  if (existingTemplate.userId !== req.user._id) {
    return new ApiResponse(403, "Access denied").send(res);
  }

  const careTemplate = await careTemplateService.updateCareTemplate(req.params.id, req.body);
  return new ApiResponse(200, "Care template updated successfully", { careTemplate }).send(res);
});

/**
 * Delete a care template
 */
export const deleteCareTemplate = catchAsyncError<UserRequest>(async (req, res) => {
  // First check if the care template exists and belongs to the user
  const existingTemplate = await careTemplateService.getCareTemplateById(req.params.id);
  
  if (!existingTemplate) {
    return new ApiResponse(404, "Care template not found").send(res);
  }

  if (existingTemplate.userId !== req.user._id) {
    return new ApiResponse(403, "Access denied").send(res);
  }

  const result = await careTemplateService.deleteCareTemplate(req.params.id);
  return new ApiResponse(200, result.message).send(res);
});

/**
 * Get care templates by status
 */
export const getCareTemplatesByStatus = catchAsyncError<UserRequest>(async (req, res) => {
  const status = req.params.status as "pending" | "approved" | "in_progress" | "completed";
  
  if (!["pending", "approved", "in_progress", "completed"].includes(status)) {
    return new ApiResponse(400, "Invalid status").send(res);
  }

  const careTemplates = await careTemplateService.getCareTemplatesByStatus(req.user._id, status);
  return new ApiResponse(200, "Care templates retrieved successfully", { careTemplates }).send(res);
});

/**
 * Get care template statistics for current user
 */
export const getCareTemplateStats = catchAsyncError<UserRequest>(async (req, res) => {
  const stats = await careTemplateService.getCareTemplateStats(req.user._id);
  return new ApiResponse(200, "Care template statistics retrieved successfully", { stats }).send(res);
}); 