import { CrystalMessage, CrystalSession } from "./model";
import { ICrystalMessage, ICrystalSession, MistralAIRequest, MistralAIResponse } from "./type";
import { Types } from "mongoose";
import { AppError } from "../../utils/api.errors";
import crypto from "crypto";
import fetch from "node-fetch";

import { MISTRAL_API_KEY, MISTRAL_URL } from "../../config/env";

export class CrystalAIService {
  private readonly MISTRAL_API_URL = MISTRAL_URL || "https://api.mistral.ai/v1/chat/completions";
  private readonly MISTRAL_API_KEY = MISTRAL_API_KEY;
  private readonly SYSTEM_PROMPT = `You are Crystal, a confident and knowledgeable AI health assistant specializing in women's reproductive health, with particular expertise in ovarian cysts and gynecological conditions. 

You provide clear, evidence-based information and practical guidance. You are direct, informative, and supportive without being overly apologetic. You have extensive knowledge about:

OVARIAN CYSTS:
- Types: functional cysts (follicular, corpus luteum), dermoid cysts, cystadenomas, endometriomas
- Symptoms: pelvic pain, bloating, irregular periods, pain during intercourse, urinary urgency
- Risk factors: age, hormonal imbalances, endometriosis, PCOS
- Diagnostic methods: ultrasound, blood tests (CA-125), MRI
- Treatment options: watchful waiting, birth control pills, surgery (laparoscopy/laparotomy)
- When to seek immediate care: severe pain, fever, rapid breathing, dizziness

You provide practical advice while always recommending professional medical consultation for diagnosis and treatment. You are confident in your knowledge and provide clear, actionable information.`;

  /**
   * Send message to Crystal AI and get response
   */
  async sendMessage(userId: string, message: string, sessionId?: string) {
    console.log('🤖 Crystal AI: Received message:', message);
    console.log('🤖 Crystal AI: User ID:', userId);
    console.log('🤖 Crystal AI: Session ID:', sessionId);
    
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

    console.log('🤖 Crystal AI: Calling Mistral AI...');
    
    // Call Mistral AI
    const aiResponse = await this.callMistralAI(messages);
    
    console.log('🤖 Crystal AI: Got response:', aiResponse);

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
    console.log('🤖 Crystal AI: Checking Mistral API configuration...');
    console.log('🤖 Crystal AI: MISTRAL_API_KEY exists:', !!this.MISTRAL_API_KEY);
    console.log('🤖 Crystal AI: MISTRAL_API_URL:', this.MISTRAL_API_URL);
    
    if (!this.MISTRAL_API_KEY) {
      console.log('🤖 Crystal AI: No API key configured, using fallback responses');
      // Return a fallback response when API key is not configured
      const lastMessage = messages[messages.length - 1]?.content || "";
      
      // Simple keyword-based responses for common health questions
      const lowerMessage = lastMessage.toLowerCase();
      
      if (lowerMessage.includes('ovarian cyst') || lowerMessage.includes('cyst')) {
        return "Ovarian cysts are fluid-filled sacs that develop in or on your ovaries. There are several types: functional cysts (most common), dermoid cysts, cystadenomas, and endometriomas. Most functional cysts resolve on their own within 1-3 months. Symptoms include pelvic pain, bloating, irregular periods, and pain during intercourse. If you experience severe pain, fever, or rapid breathing, seek immediate medical care. For diagnosis, your doctor will likely order an ultrasound and possibly blood tests. Treatment depends on cyst type and symptoms - options include watchful waiting, birth control pills, or surgery.";
      } else if (lowerMessage.includes('menstrual') || lowerMessage.includes('period') || lowerMessage.includes('cycle')) {
        return "Normal menstrual cycles range from 21-35 days, with periods lasting 2-7 days. Irregular periods can result from stress, hormonal imbalances, PCOS, thyroid issues, or other conditions. Tracking your cycle helps identify patterns. If you have persistent irregular periods or severe symptoms, consult a healthcare provider for evaluation.";
      } else if (lowerMessage.includes('pain') || lowerMessage.includes('hurt')) {
        return "Pelvic pain can have various causes including ovarian cysts, endometriosis, fibroids, or infections. The location, intensity, and timing of pain help determine the cause. Severe, sudden pain requires immediate medical attention. For persistent pain, schedule an appointment with your gynecologist for proper evaluation.";
      } else if (lowerMessage.includes('symptom')) {
        return "Common ovarian cyst symptoms include pelvic pain (especially on one side), bloating, irregular periods, pain during intercourse, and urinary urgency. Other symptoms may include nausea, breast tenderness, and lower back pain. Track your symptoms and discuss them with your healthcare provider for proper diagnosis.";
      } else {
        return "I'm Crystal, your women's health assistant. I can provide information about ovarian cysts, menstrual health, reproductive conditions, and general gynecological topics. What specific health question do you have?";
      }
    }

    const requestBody: MistralAIRequest = {
      model: "mistral-large-latest",
      messages,
      max_tokens: 1000,
      temperature: 0.7,
      top_p: 0.9
    };

    console.log('🤖 Crystal AI: Sending request to Mistral AI...');
    console.log('🤖 Crystal AI: Request URL:', this.MISTRAL_API_URL);
    console.log('🤖 Crystal AI: Request body:', JSON.stringify(requestBody, null, 2));

    try {
      const response = await fetch(this.MISTRAL_API_URL, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${this.MISTRAL_API_KEY}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify(requestBody)
      });

      console.log('🤖 Crystal AI: Response status:', response.status);
      console.log('🤖 Crystal AI: Response headers:', Object.fromEntries(response.headers.entries()));

      if (!response.ok) {
        const errorData = await response.text();
        console.error("🤖 Crystal AI: Mistral AI API Error:", errorData);
        console.error("🤖 Crystal AI: Response status:", response.status);
        throw new AppError(500, `Failed to get response from AI: ${response.status} ${errorData}`);
      }

      const data = await response.json() as MistralAIResponse;
      console.log('🤖 Crystal AI: Mistral AI response:', JSON.stringify(data, null, 2));
      
      const content = data.choices[0]?.message?.content;
      console.log('🤖 Crystal AI: Generated content:', content);
      
      return content || "I'm sorry, I couldn't generate a response at the moment.";
    } catch (error) {
      console.error("🤖 Crystal AI: Mistral AI API Error:", error);
      throw new AppError(500, `Failed to communicate with AI service: ${error}`);
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