import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { JWT_SECRET } from '../../config/env';

interface PatientTokenPayload {
  patientId: string;
  email: string;
  type: string;
}

export const authPatient = (req: Request, res: Response, next: NextFunction) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided.',
      });
    }

    const decoded = jwt.verify(token, JWT_SECRET) as PatientTokenPayload;

    // Verify that this is a patient token
    if (decoded.type !== 'patient') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token type. Patient token required.',
      });
    }

    (req as any).user = {
      patientId: decoded.patientId,
      email: decoded.email,
      type: decoded.type,
    };

    next();
  } catch (error) {
    console.error('Patient authentication error:', error);
    return res.status(401).json({
      success: false,
      message: 'Invalid token.',
    });
  }
}; 