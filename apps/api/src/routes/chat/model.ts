import mongoose, { Schema, Model } from "mongoose";
import { IMessage, IChatRoom } from "./type";

const MessageSchema: Schema<IMessage> = new Schema(
  {
    senderId: { type: String, required: true },
    receiverId: { type: String, required: true },
    content: { type: String, required: true },
    messageType: { type: String, enum: ["text", "image", "file"], default: "text" },
    isRead: { type: Boolean, default: false }
  },
  { timestamps: true }
);

const ChatRoomSchema: Schema<IChatRoom> = new Schema(
  {
    participants: [{ type: String, required: true }],
    lastMessage: { type: Schema.Types.ObjectId, ref: "Message" },
    unreadCount: { type: Map, of: Number, default: {} }
  },
  { timestamps: true }
);

// Create indexes
MessageSchema.index({ senderId: 1, receiverId: 1 });
MessageSchema.index({ createdAt: 1 });
ChatRoomSchema.index({ participants: 1 });

const Message: Model<IMessage> = mongoose.model<IMessage>("Message", MessageSchema);
const ChatRoom: Model<IChatRoom> = mongoose.model<IChatRoom>("ChatRoom", ChatRoomSchema);

export { Message, ChatRoom }; 