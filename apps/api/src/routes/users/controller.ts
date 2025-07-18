import { catchAsyncError } from "../../utils/api.catcher";
import { ApiResponse } from "../../utils/api.response";
import { AdminRequest } from "../../types/auth";
import generateTokenAndSetCookies from "../../utils/login-token";
import { UserService } from "./service";
import { UserRole } from "./type";

// Create a singleton instance of UserService
const userService = new UserService();

/**
 * Get the current user
 */
export const getCurrentUser = catchAsyncError(async (req, res) => {
  const user = await userService.getUserById((req as any).user._id);

  if (!user) {
    return new ApiResponse(404, "User not found").send(res);
  }

  return new ApiResponse(200, "User found", { user }).send(res);
});

/**
 * Get all users (admin only)
 */
export const getAllUsers = catchAsyncError<AdminRequest>(async (req, res) => {
  const data = await userService.getAllUsers(req.query);
  return new ApiResponse(200, "Users retrieved successfully", data).send(res);
});

/**
 * Get users by role (admin only)
 */
export const getUsersByRole = catchAsyncError<AdminRequest>(async (req, res) => {
  const { role } = req.params;
  const data = await userService.getUsersByRole(role as UserRole, req.query);
  return new ApiResponse(200, "Users retrieved successfully", data).send(res);
});

/**
 * Update current user
 */
export const updateCurrentUser = catchAsyncError(
  async (req, res) => {
    const updatedUser = await userService.updateUser((req as any).user._id, req.body);

    if (!updatedUser) {
      return new ApiResponse(404, "User not found").send(res);
    }

    return new ApiResponse(200, "User updated successfully", {
      user: updatedUser,
    }).send(res);
  }
);

/**
 * Delete current user
 */
export const deleteCurrentUser = catchAsyncError(
  async (req, res) => {
    const deletedUser = await userService.deleteUser((req as any).user._id);

    if (!deletedUser) {
      return new ApiResponse(404, "User not found").send(res);
    }

    return new ApiResponse(200, "User deleted successfully").send(res);
  }
);

/**
 * User registration
 */
export const registerUser = catchAsyncError(async (req, res) => {
  const user = await userService.registerUser(req.body);

  // Generate auth token and set cookies
  const token = generateTokenAndSetCookies(user._id, res);

  return new ApiResponse(201, "Registration successful", { user, token  }).send(res);
});

/**
 * User login
 */
export const loginUser = catchAsyncError(async (req, res) => {
  const { email, password } = req.body;
  const user = await userService.authenticateUser(email, password);

  // Generate auth token and set cookies
  const token = generateTokenAndSetCookies(user._id, res);

  return new ApiResponse(200, "Login successful", { user, token }).send(res);
});

/**
 * Reset password
 */
export const resetPassword = catchAsyncError(async (req, res) => {
  const { token, newPassword } = req.body;
  await userService.resetPassword(token, newPassword);
  return new ApiResponse(200, "Password reset successfully").send(res);
});

/**
 * Request password reset
 */
export const requestPasswordReset = catchAsyncError(
  async (req, res) => {
    const { email } = req.body;
    await userService.requestPasswordReset(email);
    return new ApiResponse(200, "Password reset token sent to email").send(res);
  }
);

/**
 * Create a new user (admin only)
 */
export const createUser = catchAsyncError<AdminRequest>(async (req, res) => {
  const user = await userService.createUser(req.body);
  return new ApiResponse(201, "User created successfully", { user }).send(res);
});

/**
 * Get user by ID (admin only)
 */
export const getUserById = catchAsyncError<AdminRequest>(async (req, res) => {
  const user = await userService.getUserById(req.params.id);

  if (!user) {
    return new ApiResponse(404, "User not found").send(res);
  }

  return new ApiResponse(200, "User found", { user }).send(res);
});

/**
 * Update user by ID (admin only)
 */
export const updateUserById = catchAsyncError<AdminRequest>(
  async (req, res) => {
    const updatedUser = await userService.updateUser(req.params.id, req.body);

    if (!updatedUser) {
      return new ApiResponse(404, "User not found").send(res);
    }

    return new ApiResponse(200, "User updated successfully", {
      user: updatedUser,
    }).send(res);
  }
);

/**
 * Delete user by ID (admin only)
 */
export const deleteUserById = catchAsyncError<AdminRequest>(
  async (req, res) => {
    const deletedUser = await userService.deleteUser(req.params.id);

    if (!deletedUser) {
      return new ApiResponse(404, "User not found").send(res);
    }

    return new ApiResponse(200, "User deleted successfully").send(res);
  }
);
