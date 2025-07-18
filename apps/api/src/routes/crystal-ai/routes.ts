import { Router } from "express";
import * as Controller from "./controller";
import { authUser } from "../../middleware/auth/auth-user";

const router = Router();

// Test route without authentication
router.get("/test", (req, res) => {
  console.log("🤖 Crystal AI: Test route hit");
  res.json({ message: "Crystal AI routes are working!" });
});

router.use(authUser);

// Send a message to Crystal AI
router.post("/talk", Controller.talkToCrystal);

// Get all chat sessions for the user
router.get("/sessions", Controller.getSessions);

// Get a session with its messages
router.get("/sessions/:sessionId", Controller.getSessionWithMessages);

// Delete a session and its messages
router.delete("/sessions/:sessionId", Controller.deleteSession);

export default router; 