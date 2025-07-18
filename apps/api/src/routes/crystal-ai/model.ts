import mongoose, { Schema, Model } from "mongoose";
import { ICrystalMessage, ICrystalSession } from "./type";

const CrystalMessageSchema: Schema<ICrystalMessage> = new Schema(
  {
    userId: { type: String, required: true },
    message: { type: String, default: "" },
    response: { type: String, default: "" },
    messageType: { type: String, enum: ["user", "crystal"], required: true },
    timestamp: { type: Date, default: Date.now },
    sessionId: { type: String, required: true }
  },
  { timestamps: true }
);

const CrystalSessionSchema: Schema<ICrystalSession> = new Schema(
  {
    userId: { type: String, required: true },
    sessionId: { type: String, required: true, unique: true },
    title: { type: String, required: true },
    lastMessage: { type: String, required: true },
    messageCount: { type: Number, default: 0 }
  },
  { timestamps: true }
);

// Create indexes
CrystalMessageSchema.index({ userId: 1, sessionId: 1 });
CrystalMessageSchema.index({ timestamp: 1 });
CrystalSessionSchema.index({ userId: 1 });

const CrystalMessage: Model<ICrystalMessage> = mongoose.model<ICrystalMessage>("CrystalMessage", CrystalMessageSchema);
const CrystalSession: Model<ICrystalSession> = mongoose.model<ICrystalSession>("CrystalSession", CrystalSessionSchema);

export { CrystalMessage, CrystalSession }; 