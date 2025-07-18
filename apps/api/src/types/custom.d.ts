import { Request } from 'express';

declare module 'express-serve-static-core' {
  interface Request {
    user?: {
      _id?: string;
      patientId?: string;
      email?: string;
      type?: string;
      role?: string;
      [key: string]: any;
    };
  }
} 