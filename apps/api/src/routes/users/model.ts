import mongoose, { Schema, Model } from "mongoose";
import bcrypt from "bcrypt";
import { IUser, UserStatus, UserRole } from "./type";

// Main User schema definition
const UserSchema: Schema<IUser> = new Schema(
  {
    username: { type: String, unique: true },
    name: { type: String },
    email: { type: String, unique: true, lowercase: true },
    password: { type: String, select: false },
    status: { type: String, enum: Object.values(UserStatus), default: UserStatus.ACTIVE },
    role: { type: String, enum: Object.values(UserRole), default: UserRole.USER },
    phone: { type: String },
    lastLogin: { type: Date },
    avatar: { type: String },
    bio: { type: String },
    referredBy: { type: String },
    // CodeHer specific fields
    age: { type: Number },
    hospital: { type: String }, // Hospital/Clinic name for doctors
    region: { type: String }, // Region for doctors
    riskLevel: { type: String, enum: ["Low", "Moderate", "High"] },
    healthPreferences: {
      notifications: { type: Boolean, default: true },
      privacyLevel: { type: String, enum: ["public", "private", "friends"], default: "private" },
      language: { type: String, default: "en" }
    },
    emergencyContact: {
      name: { type: String },
      phone: { type: String },
      relationship: { type: String }
    }
  },
  { timestamps: true }
);

// Pre-save hook to hash the password before saving
UserSchema.pre<IUser>("save", async function (next) {
  if (!this.isModified("password")) return next();

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Instance method to compare passwords
UserSchema.methods.comparePassword = async function (
  candidatePassword: string
): Promise<boolean> {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Static method for finding a user by email
UserSchema.statics.findByEmail = async function (
  email: string
): Promise<IUser | null> {
  return await this.findOne({ email });
};

// Create and export the User model
const User: Model<IUser> = mongoose.model<IUser>("User", UserSchema);

export default User;
