import { Router } from "express";
import { authUser } from "../../middleware/auth/auth-user";
import {
  createCareTemplate,
  getCareTemplateById,
  getUserLatestCareTemplate,
  getUserCareTemplates,
  updateCareTemplate,
  deleteCareTemplate,
  getCareTemplatesByStatus,
  getCareTemplateStats
} from "./controller";

const router = Router();

// All routes require user authentication
router.use(authUser);

// Care template routes
router.post("/", createCareTemplate);
router.get("/latest", getUserLatestCareTemplate);
router.get("/stats", getCareTemplateStats);
router.get("/status/:status", getCareTemplatesByStatus);
router.get("/", getUserCareTemplates);
router.get("/:id", getCareTemplateById);
router.put("/:id", updateCareTemplate);
router.delete("/:id", deleteCareTemplate);

export default router; 