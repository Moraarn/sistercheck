import { Request } from 'express';

declare global {
  namespace Express {
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
}

export {}; 