import Admin from "./model";
import { IAdmin } from "./type";
import { Types } from "mongoose";
import { AppError } from "../../utils/api.errors";

export class AdminService {
  /**
   * Get admin by ID
   */
  async getAdminById(adminId: string | Types.ObjectId) {
    return await Admin.findById(adminId).lean();
  }

  /**
   * Update admin by ID
   */
  async updateAdmin(
    adminId: string | Types.ObjectId,
    updateData: Partial<IAdmin>
  ) {
    return await Admin.findByIdAndUpdate(adminId, updateData, {
      new: true,
      runValidators: true,
    }).lean();
  }

  /**
   * Authenticate admin
   */
  async authenticateAdmin(email: string, password: string) {
    const admin = await Admin.findOne({ email }).select("+password").exec();

    if (!admin) {
      throw new AppError(401, "Invalid email or password");
    }

    const isMatch = await admin.comparePassword(password);

    if (!isMatch) {
      throw new AppError(401, "Invalid email or password");
    }

    return admin.toObject();
  }

  /**
   * Create a new admin
   */
  async createAdmin(adminData: Partial<IAdmin>) {
    return await Admin.create(adminData);
  }
} 