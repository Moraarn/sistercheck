import { Router } from "express";
import * as Controller from "./controller";
import { authUser } from "../../middleware/auth/auth-user";

const router = Router();

// All routes require authentication
router.use(authUser);

// CRUD operations
router.post("/", Controller.createSymptom);
router.get("/latest", Controller.getUserLatestSymptom);
router.get("/stats", Controller.getSymptomStats);
router.get("/recent", Controller.getRecentSymptoms);
router.get("/severity/:severity", Controller.getSymptomsBySeverity);
router.get("/", Controller.getUserSymptoms);
router.get("/:id", Controller.getSymptomById);
router.put("/:id", Controller.updateSymptom);
router.delete("/:id", Controller.deleteSymptom);

export default router; 