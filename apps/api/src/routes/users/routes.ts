import { Router } from "express";
import * as Controller from "./controller";
import { authUser } from "../../middleware/auth/auth-user";
import { authAdmin } from "../../middleware/auth/auth-admin";

const router = Router();

router.post("/request-password-reset", Controller.requestPasswordReset);
router.post("/reset-password", Controller.resetPassword);
router.post("/signup", Controller.registerUser);
router.post("/signin", Controller.loginUser);

router.get("/account", authUser, Controller.getCurrentUser);

router.put("/", authUser, Controller.updateCurrentUser);
router.delete("/", authUser, Controller.deleteCurrentUser);

// Admin routes
router.use(authAdmin);

router.post("/", Controller.createUser);
router.get("/role/:role", Controller.getUsersByRole);
router.get("/:id", Controller.getUserById);
router.put("/:id", Controller.updateUserById);
router.delete("/:id", Controller.deleteUserById);
router.get("/", Controller.getAllUsers);

export default router;
