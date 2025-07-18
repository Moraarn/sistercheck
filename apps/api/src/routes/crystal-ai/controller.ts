import { catchAsyncError } from "../../utils/api.catcher";
import { ApiResponse } from "../../utils/api.response";
import { UserRequest } from "../../types/auth";
import { CrystalAIService } from "./service";

const crystalAIService = new CrystalAIService();

/**
 * Send a message to Crystal AI and get a response
 */
export const talkToCrystal = catchAsyncError<UserRequest>(async (req, res) => {
  console.log("🤖 Crystal AI: Received request to /talk");
  console.log("🤖 Crystal AI: User:", req.user?._id);
  console.log("🤖 Crystal AI: Body:", req.body);
  
  const { message, sessionId } = req.body;
  if (!message) {
    console.log("🤖 Crystal AI: No message provided");
    return new ApiResponse(400, "Message is required").send(res);
  }
  
  console.log("🤖 Crystal AI: Processing message:", message);
  const result = await crystalAIService.sendMessage(req.user._id, message, sessionId);
  console.log("🤖 Crystal AI: Service result:", result);
  
  return new ApiResponse(200, "Crystal AI response", result).send(res);
});

/**
 * Get all chat sessions for the user
 */
export const getSessions = catchAsyncError<UserRequest>(async (req, res) => {
  console.log("🤖 Crystal AI: Getting sessions for user:", req.user?._id);
  const sessions = await crystalAIService.getUserSessions(req.user._id);
  return new ApiResponse(200, "Sessions retrieved", { sessions }).send(res);
});

/**
 * Get a session with its messages
 */
export const getSessionWithMessages = catchAsyncError<UserRequest>(async (req, res) => {
  const { sessionId } = req.params;
  console.log("🤖 Crystal AI: Getting session with messages:", sessionId);
  const data = await crystalAIService.getSessionWithMessages(sessionId, req.user._id);
  return new ApiResponse(200, "Session and messages retrieved", data).send(res);
});

/**
 * Delete a session and its messages
 */
export const deleteSession = catchAsyncError<UserRequest>(async (req, res) => {
  const { sessionId } = req.params;
  console.log("🤖 Crystal AI: Deleting session:", sessionId);
  const result = await crystalAIService.deleteSession(sessionId, req.user._id);
  return new ApiResponse(200, result.message).send(res);
}); 