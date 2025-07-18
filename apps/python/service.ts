import { CrystalMessage, CrystalSession } from "./model";
import { ICrystalMessage, ICrystalSession, MistralAIRequest, MistralAIResponse } from "./type";
import { Types } from "mongoose";
import { AppError } from "../../utils/api.errors";
import crypto from "crypto";
import fetch from "node-fetch";

export class CrystalAIService {
  private readonly MISTRAL_API_URL = "https://api.mistral.ai/v1/chat/completions";
  private readonly MISTRAL_API_KEY = process.env.MISTRAL_API_KEY;
  private readonly SYSTEM_PROMPT = `You are Crystal, a compassionate and knowledgeable AI health assistant specializing in women's health. You provide supportive, evidence-based information about reproductive health, menstrual cycles, ovarian cysts, and general wellness. Always be empathetic, professional, and encourage users to consult healthcare providers for serious concerns. Keep responses informative but not overwhelming.`;

  /**
   * Send message to Crystal AI and get response
   */
  async sendMessage(userId: string, message: string, sessionId?: string) {
    // Create or get session
    const session = sessionId 
      ? await this.getSession(sessionId, userId)
      : await this.createSession(userId, message);

    // Get conversation history for context
    const conversationHistory = await this.getConversationHistory(session.sessionId);

    // Prepare messages for Mistral AI
    const messages = [
      { role: "system" as const, content: this.SYSTEM_PROMPT },
      ...conversationHistory.map(msg => ({
        role: msg.messageType === "user" ? "user" as const : "assistant" as const,
        content: msg.messageType === "user" ? msg.message : msg.response
      })),
      { role: "user" as const, content: message }
    ];

    // Call Mistral AI
    const aiResponse = await this.callMistralAI(messages);

    // Save the conversation
    await this.saveMessage(userId, session.sessionId, message, aiResponse, "user");
    await this.saveMessage(userId, session.sessionId, aiResponse, "", "crystal");

    // Update session
    await this.updateSession(session.sessionId, message, aiResponse);

    return {
      response: aiResponse,
      sessionId: session.sessionId,
      sessionTitle: session.title
    };
  }

  /**
   * Create a new chat session
   */
  async createSession(userId: string, firstMessage: string): Promise<ICrystalSession> {
    const sessionId = crypto.randomBytes(16).toString("hex");
    const title = this.generateSessionTitle(firstMessage);

    const session = await CrystalSession.create({
      userId,
      sessionId,
      title,
      lastMessage: firstMessage,
      messageCount: 0
    });

    return session.toObject();
  }

  /**
   * Get existing session
   */
  async getSession(sessionId: string, userId: string): Promise<ICrystalSession> {
    const session = await CrystalSession.findOne({ sessionId, userId }).lean();
    
    if (!session) {
      throw new AppError(404, "Session not found");
    }

    return session;
  }

  /**
   * Get user's chat sessions
   */
  async getUserSessions(userId: string) {
    return await CrystalSession.find({ userId })
      .sort({ updatedAt: -1 })
      .lean();
  }

  /**
   * Get conversation history for a session
   */
  async getConversationHistory(sessionId: string) {
    return await CrystalMessage.find({ sessionId })
      .sort({ timestamp: 1 })
      .lean();
  }

  /**
   * Get session with messages
   */
  async getSessionWithMessages(sessionId: string, userId: string) {
    const session = await this.getSession(sessionId, userId);
    const messages = await this.getConversationHistory(sessionId);

    return {
      session,
      messages
    };
  }

  /**
   * Delete a session and all its messages
   */
  async deleteSession(sessionId: string, userId: string) {
    const session = await this.getSession(sessionId, userId);
    
    // Delete all messages in the session
    await CrystalMessage.deleteMany({ sessionId });
    
    // Delete the session
    await CrystalSession.findByIdAndDelete(session._id);
    
    return { message: "Session deleted successfully" };
  }

  /**
   * Call Mistral AI API
   */
  private async callMistralAI(messages: Array<{ role: "user" | "assistant" | "system"; content: string }>): Promise<string> {
    if (!this.MISTRAL_API_KEY) {
      throw new AppError(500, "Mistral AI API key not configured");
    }

    const requestBody: MistralAIRequest = {
      model: "mistral-large-latest",
      messages,
      max_tokens: 1000,
      temperature: 0.7,
      top_p: 0.9
    };

    try {
      const response = await fetch(this.MISTRAL_API_URL, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${this.MISTRAL_API_KEY}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify(requestBody)
      });

      if (!response.ok) {
        const errorData = await response.text();
        console.error("Mistral AI API Error:", errorData);
        throw new AppError(500, "Failed to get response from AI");
      }

      const data = await response.json() as MistralAIResponse;
      return data.choices[0]?.message?.content || "I'm sorry, I couldn't generate a response at the moment.";
    } catch (error) {
      console.error("Mistral AI API Error:", error);
      throw new AppError(500, "Failed to communicate with AI service");
    }
  }

  /**
   * Save a message to the database
   */
  private async saveMessage(
    userId: string, 
    sessionId: string, 
    message: string, 
    response: string, 
    messageType: "user" | "crystal"
  ) {
    await CrystalMessage.create({
      userId,
      sessionId,
      message: messageType === "user" ? message : "",
      response: messageType === "crystal" ? message : response,
      messageType,
      timestamp: new Date()
    });
  }

  /**
   * Update session with latest message
   */
  private async updateSession(sessionId: string, lastMessage: string, lastResponse: string) {
    await CrystalSession.findOneAndUpdate(
      { sessionId },
      {
        lastMessage: lastMessage,
        $inc: { messageCount: 2 } // Increment by 2 (user message + AI response)
      }
    );
  }

  /**
   * Generate a session title from the first message
   */
  private generateSessionTitle(message: string): string {
    const words = message.split(" ").slice(0, 5).join(" ");
    return words.length > 30 ? words.substring(0, 30) + "..." : words;
  }
} 