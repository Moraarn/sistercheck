import { Document } from "mongoose";

export interface ICrystalMessage extends Document {
  _id: string;
  userId: string;
  message: string;
  response: string;
  messageType: "user" | "crystal";
  timestamp: Date;
  sessionId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface ICrystalSession extends Document {
  _id: string;
  userId: string;
  sessionId: string;
  title: string;
  lastMessage: string;
  messageCount: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface MistralAIRequest {
  model: string;
  messages: Array<{
    role: "user" | "assistant" | "system";
    content: string;
  }>;
  max_tokens?: number;
  temperature?: number;
  top_p?: number;
  stream?: boolean;
}

export interface MistralAIResponse {
  id: string;
  object: string;
  created: number;
  model: string;
  choices: Array<{
    index: number;
    message: {
      role: string;
      content: string;
    };
    finish_reason: string;
  }>;
  usage: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
} 