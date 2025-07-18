import { Router } from "express";
import * as Controller from "./controller";
import { authUser } from "../../middleware/auth/auth-user";

const router = Router();

// All routes require authentication
router.use(authUser);

router.post("/", Controller.createRiskAssessment);
router.get("/latest", Controller.getUserLatestAssessment);
router.get("/", Controller.getUserAssessments);
router.get("/:id", Controller.getRiskAssessmentById);

export default router; 