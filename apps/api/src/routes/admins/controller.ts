import { catchAsyncError } from "../../utils/api.catcher";
import { ApiResponse } from "../../utils/api.response";
import { AdminRequest } from "../../types/auth";
import generateTokenAndSetCookies from "../../utils/login-token";
import { AdminService } from "./service";

const adminService = new AdminService();

/**
 * Admin login
 */
export const loginAdmin = catchAsyncError(async (req, res) => {
  const { email, password } = req.body;
  const admin = await adminService.authenticateAdmin(email, password);

  // Generate auth token and set cookies
  generateTokenAndSetCookies(admin._id, res);

  return new ApiResponse(200, "Admin login successful").send(res);
});

/**
 * Get admin profile
 */
export const getAdminProfile = catchAsyncError<AdminRequest>(async (req, res) => {
  const admin = await adminService.getAdminById(req.admin._id);

  if (!admin) {
    return new ApiResponse(404, "Admin not found").send(res);
  }

  return new ApiResponse(200, "Admin profile found", { admin }).send(res);
});

/**
 * Update admin profile
 */
export const updateAdminProfile = catchAsyncError<AdminRequest>(async (req, res) => {
  const updatedAdmin = await adminService.updateAdmin(req.admin._id, req.body);

  if (!updatedAdmin) {
    return new ApiResponse(404, "Admin not found").send(res);
  }

  return new ApiResponse(200, "Admin profile updated successfully", {
    admin: updatedAdmin,
  }).send(res);
}); 