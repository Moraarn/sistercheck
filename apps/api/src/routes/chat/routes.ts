import { Router } from "express";
import * as Controller from "./controller";
import { authUser } from "../../middleware/auth/auth-user";

const router = Router();

// All routes require authentication
router.use(authUser);

router.post("/", Controller.sendMessage);
router.get("/rooms", Controller.getUserChatRooms);
router.get("/unread-count", Controller.getUnreadCount);
router.get("/:receiverId", Controller.getMessages);
router.patch("/:senderId/read", Controller.markMessagesAsRead);
router.delete("/:id", Controller.deleteMessage);

export default router; 