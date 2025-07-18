import mongoose, { Schema, Model } from "mongoose";
import bcrypt from "bcrypt";
import { IAdmin } from "./type";

const AdminSchema: Schema<IAdmin> = new Schema(
  {
    username: { type: String, unique: true, required: true },
    email: { type: String, unique: true, lowercase: true, required: true },
    password: { type: String, select: false, required: true },
    role: { type: String, default: "admin" },
    permissions: [{ type: String }]
  },
  { timestamps: true }
);

// Pre-save hook to hash the password before saving
AdminSchema.pre<IAdmin>("save", async function (next) {
  if (!this.isModified("password")) return next();

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Instance method to compare passwords
AdminSchema.methods.comparePassword = async function (
  candidatePassword: string
): Promise<boolean> {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Create and export the Admin model
const Admin: Model<IAdmin> = mongoose.model<IAdmin>("Admin", AdminSchema);

export default Admin; 