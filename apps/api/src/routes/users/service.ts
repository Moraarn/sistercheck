import User from "./model";
import { IUser, UserRole } from "./type";
import sendEmail from "../../utils/mailer";
import { Types } from "mongoose";
import crypto from "crypto";
import { AppError } from "../../utils/api.errors";

export class UserService {

  /**
   * Create a new user
   */
  async createUser(userData: IUser) {
    return await User.create(userData);
  }

  /**
   * Get user by ID
   */
  async getUserById(userId: string | Types.ObjectId) {
    return await User.findById(userId).lean();
  }

  /**
   * Get all users with pagination and filtering
   */
  async getAllUsers(query: any) {
    const apiFeature = new (
      await import("../../utils/api.features")
    ).ApiFeatures(User.find(), query)
      .pagination()
      .fields()
      .search()
      .filteration()
      .sort();

    return await apiFeature.getPaginatedData<[]>();
  }

  /**
   * Update user by ID
   */
  async updateUser(
    userId: string | Types.ObjectId,
    updateData: Partial<IUser>
  ) {
    return await User.findByIdAndUpdate(userId, updateData, {
      new: true,
      runValidators: true,
    }).lean();
  }

  /**
   * Delete user by ID
   */
  async deleteUser(userId: string | Types.ObjectId) {
    return await User.findByIdAndDelete(userId).lean();
  }

  /**
   * Register a new user
   */
  async registerUser(userData: {
    username: string;
    email: string;
    password: string;
    role?: UserRole;
    name?: string;
    age?: number;
    hospital?: string;
    region?: string;
    referralCode?: string;
  }) {
    const { username, referralCode, email, password, role = UserRole.USER, ...otherData } = userData;

    // Check if the email already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      throw new AppError(400, "Email already exists");
    }

    // Check if the username already exists
    const existingUsername = await User.findOne({ username });
    if (existingUsername) {
      throw new AppError(400, "Username already exists");
    }

    let referredBy = null;

    // If referralCode is provided, store it directly (since we don't have Athlete model)
    if (referralCode) {
      referredBy = referralCode; // Store referral code as string
    }

    // Create and save new user
    const user: IUser = new User({
      username,
      email,
      password,
      role,
      referredBy,
      ...otherData
    });

    await user.save();
    return user.toObject();
  }

  /**
   * Authenticate user
   */
  async authenticateUser(email: string, password: string) {
    const user = await User.findOne({ email }).select("+password").exec();

    if (!user) {
      throw new AppError(401, "Invalid email or password");
    }

    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
      throw new AppError(401, "Invalid email or password");
    }

    // Update last login
    await User.findByIdAndUpdate(user._id, { lastLogin: new Date() });

    return user.toObject();
  }

  /**
   * Reset password with token
   */
  async resetPassword(token: string, newPassword: string) {
    // Find the user with the valid token and ensure token has not expired
    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpires: { $gt: new Date() },
    });

    if (!user) {
      throw new Error("Invalid or expired token");
    }

    user.password = newPassword;

    await user.save();
    return true;
  }

  /**
   * Request password reset
   */
  async requestPasswordReset(email: string) {
    const user = await User.findOne({ email });

    if (!user) {
      throw new Error("User not found");
    }

    // Generate a reset token
    const resetToken = crypto.randomBytes(32).toString("hex");

    await user.save();

    // Send email with reset token
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: user.email,
      subject: "Password Reset Request",
      html: `You requested a password reset. Please use the following token to reset your password: ${resetToken}`,
    };

    await sendEmail(mailOptions);
    return true;
  }

  /**
   * Get users by role
   */
  async getUsersByRole(role: UserRole, query: any) {
    const apiFeature = new (
      await import("../../utils/api.features")
    ).ApiFeatures(User.find({ role }), query)
      .pagination()
      .fields()
      .search()
      .filteration()
      .sort();

    return await apiFeature.getPaginatedData<[]>();
  }
}
