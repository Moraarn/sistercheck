import { Document } from "mongoose";

export interface IAdmin extends Document {
  _id: string;
  username: string;
  email: string;
  password: string;
  role: string;
  permissions: string[];
  createdAt: Date;
  updatedAt: Date;
  comparePassword(candidatePassword: string): Promise<boolean>;
} 