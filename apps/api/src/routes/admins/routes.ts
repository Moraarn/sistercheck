import { Router } from "express";
import * as Controller from "./controller";
import { authAdmin } from "../../middleware/auth/auth-admin";

const router = Router();

// Admin authentication routes (no auth required)
router.post("/signin", Controller.loginAdmin);

// Protected admin routes
router.use(authAdmin);

router.get("/profile", Controller.getAdminProfile);
router.put("/profile", Controller.updateAdminProfile);

export default router; 