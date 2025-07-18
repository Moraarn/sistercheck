import { catchAsyncError } from "../../utils/api.catcher";
import { ApiResponse } from "../../utils/api.response";
import { UserRequest } from "../../types/auth";
import { ChatService } from "./service";

// Create a singleton instance of ChatService
const chatService = new ChatService();

/**
 * Send a message
 */
export const sendMessage = catchAsyncError<UserRequest>(async (req, res) => {
  const message = await chatService.sendMessage({
    ...req.body,
    senderId: req.user._id
  });
  
  return new ApiResponse(201, "Message sent successfully", { message }).send(res);
});

/**
 * Get messages between two users
 */
export const getMessages = catchAsyncError<UserRequest>(async (req, res) => {
  const { receiverId } = req.params;
  const data = await chatService.getMessages(req.user._id, receiverId, req.query);
  return new ApiResponse(200, "Messages retrieved successfully", data).send(res);
});

/**
 * Get user's chat rooms
 */
export const getUserChatRooms = catchAsyncError<UserRequest>(async (req, res) => {
  const chatRooms = await chatService.getUserChatRooms(req.user._id);
  return new ApiResponse(200, "Chat rooms retrieved successfully", { chatRooms }).send(res);
});

/**
 * Mark messages as read
 */
export const markMessagesAsRead = catchAsyncError<UserRequest>(async (req, res) => {
  const { senderId } = req.params;
  await chatService.markMessagesAsRead(senderId, req.user._id);
  return new ApiResponse(200, "Messages marked as read").send(res);
});

/**
 * Get unread message count
 */
export const getUnreadCount = catchAsyncError<UserRequest>(async (req, res) => {
  const count = await chatService.getUnreadCount(req.user._id);
  return new ApiResponse(200, "Unread count retrieved", { count }).send(res);
});

/**
 * Delete a message
 */
export const deleteMessage = catchAsyncError<UserRequest>(async (req, res) => {
  const message = await chatService.deleteMessage(req.params.id, req.user._id);
  return new ApiResponse(200, "Message deleted successfully").send(res);
}); 