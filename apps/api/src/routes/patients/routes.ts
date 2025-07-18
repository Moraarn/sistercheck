import { Router } from 'express';
import * as Controller from './controller';
import { authUser } from '../../middleware/auth/auth-user';
import { authPatient } from '../../middleware/auth/auth-patient';

const router = Router();

// Public routes (no authentication required)
router.post('/signup', Controller.signup);
router.post('/signin', Controller.signin);

// Patient authenticated routes
// @ts-ignore
router.get('/profile', authPatient, Controller.getProfile);
// @ts-ignore
router.put('/profile', authPatient, Controller.updateProfile);
// @ts-ignore
router.post('/logout', authPatient, Controller.logout);

// Doctor/Nurse authenticated routes (for managing patients)
router.get('/', authUser, Controller.getPatients);
router.get('/search', authUser, Controller.searchPatients);
router.post('/create-with-assessment',  Controller.createPatientWithAssessment);

export default router; 