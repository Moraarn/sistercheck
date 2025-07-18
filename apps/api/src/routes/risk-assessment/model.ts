import mongoose, { Schema, Model } from "mongoose";
import { IRiskAssessment } from "./type";

const RiskAssessmentSchema: Schema<IRiskAssessment> = new Schema(
  {
    userId: { type: String, required: true },
    answers: {
      bloating: { type: Boolean, required: true },
      pelvicPain: { type: Boolean, required: true },
      irregularPeriods: { type: Boolean, required: true },
      mood: { type: String, required: true },
      exercise: { type: String, required: true }
    },
    riskLevel: { type: String, enum: ["Low", "Moderate", "High"], required: true },
    score: { type: Number, required: true },
    recommendations: [{ type: String }]
  },
  { timestamps: true }
);

// Create indexes
RiskAssessmentSchema.index({ userId: 1 });
RiskAssessmentSchema.index({ createdAt: 1 });

const RiskAssessment: Model<IRiskAssessment> = mongoose.model<IRiskAssessment>("RiskAssessment", RiskAssessmentSchema);

export default RiskAssessment; 