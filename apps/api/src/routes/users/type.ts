import { Document } from "mongoose";

export enum UserStatus {
  ACTIVE = "active",
  SUSPENDED = "suspended",
  DELETED = "inactive",
}

export enum UserRole {
  USER = "user",
  PEER_SISTER = "peer_sister",
  NURSE = "nurse",
  ADMIN = "admin",
}

// Interface for the User document (combining fields and instance methods)
export interface IUser extends Document {
  _id: string;
  username: string;
  name: string;
  email: string;
  password: string;
  status: UserStatus;
  role: UserRole;
  phone?: string;
  lastLogin?: Date;
  bio?: string;
  createdAt: Date;
  updatedAt: Date;
  comparePassword(candidatePassword: string): Promise<boolean>;
  avatar?: string;
  referredBy?: string;
  // CodeHer specific fields
  age?: number;
  hospital?: string; // Hospital/Clinic name for doctors
  region?: string; // Region for doctors
  riskLevel?: string; // Low, Moderate, High
  healthPreferences?: {
    notifications: boolean;
    privacyLevel: 'public' | 'private' | 'friends';
    language: string;
  };
  emergencyContact?: {
    name: string;
    phone: string;
    relationship: string;
  };
}
