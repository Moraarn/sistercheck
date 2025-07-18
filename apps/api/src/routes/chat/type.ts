import { Document } from "mongoose";

export interface IMessage extends Document {
  _id: string;
  senderId: string;
  receiverId: string;
  content: string;
  messageType: "text" | "image" | "file";
  isRead: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface IChatRoom extends Document {
  _id: string;
  participants: string[];
  lastMessage?: IMessage;
  unreadCount: { [userId: string]: number };
  createdAt: Date;
  updatedAt: Date;
} 