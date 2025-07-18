// Purpose: To store all the environment variables and configurations in one place.
import dotenv from "dotenv";

dotenv.config();

// Application configurations
export const APP_NAME = process.env.APP_NAME || "Express API";
export const APP_VERSION = process.env.APP_VERSION || "1.0.0";
export const APP_DESCRIPTION = process.env.APP_DESCRIPTION || "REST API built with Express.js";
export const APP_AUTHOR = process.env.APP_AUTHOR || "Author";

// mistral configurations
export const MISTRAL_URL = process.env.MISTRAL_URL || "";
export const MISTRAL_API_KEY = process.env.MISTRAL_API_KEY || "";

// Server and database configurations
export const PORT = parseInt(process.env.PORT || "5000", 10);
export const BASE_URL = process.env.BASE_URL || "";
export const JWT_SECRET = process.env.JWT_SECRET || "secret";
export const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "1d";
export const NODE_ENV = process.env.NODE_ENV || "production";
export const MONGODB_URI = process.env.MONGODB_URI || "";
export const SECRET_KEY = process.env.SECRET_KEY || "";

// Authentication-related values
export const HASH_SALT = parseInt(process.env.HASH_SALT || "10", 10);

// Mailer configurations
export const EMAIL_NAME = process.env.EMAIL_NAME || "The Naritiv";
export const EMAIL_SERVICE = process.env.EMAIL_SERVICE || "gmail";
export const EMAIL_HOST = process.env.EMAIL_HOST || "smtp.gmail.com";
export const EMAIL_PORT = process.env.EMAIL_PORT || 587;
export const EMAIL_USER = process.env.EMAIL_USER || "exteamco@gmail.com";
export const EMAIL_PASS = process.env.EMAIL_PASS || "reto znfx jexe bhsr";

// Stripe configurations
export const STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY || "";
export const STRIPE_WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET || "";

// Google Maps configurations
export const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY || "";

