import Joi from "joi";
import { IAdmin } from "../routes/admins/type";
import { IUser } from "../routes/users/type";
import { Request } from "express";

// Patient interface for auth types
interface IPatient {
  patientId: string;
  email: string;
  type: string;
}

// signin schema
export const signinSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
});

// signup schema for CodeHer: user or peer_sister
export const signupSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  username: Joi.string().required(),
  role: Joi.string().valid("user", "peer_sister").required(),
  name: Joi.string().optional(),
  age: Joi.number().integer().min(10).max(120).optional(),
  language: Joi.string().optional(),
  location: Joi.string().optional(),
  bio: Joi.string().optional(), // for peer_sister
  referralCode: Joi.string().optional(),
});

// reset password schema
export const forgotPasswordSchema = Joi.object({
  email: Joi.string().email().required(),
});

// change password schema
export const resetPasswordSchema = Joi.object({
  password: Joi.string().min(6).required(),
  newPassword: Joi.string().min(6).required(),
});

type Cookies = {
  token: string;
};

// user request type
export interface UserRequest extends Request {
  user: IUser;
  cookies: Cookies;
}

// admin request type
export interface AdminRequest extends Request {
  admin: IAdmin;
  cookies: Cookies;
}

// athlete request type (keeping for compatibility)
export interface AthleteRequest extends Request {
  athlete: any; // Changed from IAthlete to any since IAthlete doesn't exist
  cookies: Cookies;
}

// patient request type
export interface PatientRequest extends Request {
  user: IPatient;
  cookies: Cookies;
}

// Combined request type that can handle both user and patient
export interface CombinedRequest extends Request {
  user: IUser | IPatient;
  cookies: Cookies;
}


