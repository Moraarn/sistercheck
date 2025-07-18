import mongoose, { Schema, Model } from "mongoose";
import { ICareTemplate } from "./type";

const CareTemplateSchema: Schema<ICareTemplate> = new Schema(
  {
    userId: { type: String, required: true },
    symptomId: { type: String, required: false },
    riskAssessmentId: { type: String, required: false },
    patientData: {
      age: { type: Number, required: false },
      menopauseStage: { type: String, required: false },
      cystSize: { type: Number, required: false },
      cystGrowth: { type: Number, required: false },
      fca125Level: { type: Number, required: false },
      ultrasoundFeatures: { type: String, required: false },
      reportedSymptoms: { type: String, required: false }
    },
    prediction: {
      treatmentPlan: { type: String, required: true },
      confidence: { type: Number, required: true },
      probabilities: { type: Map, of: Number, required: false }
    },
    carePlan: {
      costInfo: {
        service: { type: String, required: false },
        baseCost: { type: Number, required: false },
        outOfPocket: { type: Number, required: false }
      },
      inventoryInfo: {
        item: { type: String, required: false },
        availableStock: { type: Number, required: false }
      },
      recommendations: [{ type: String }],
      nextSteps: [{ type: String }]
    },
    status: { 
      type: String, 
      enum: ["pending", "approved", "in_progress", "completed"], 
      default: "pending" 
    }
  },
  { timestamps: true }
);

// Create indexes
CareTemplateSchema.index({ userId: 1 });
CareTemplateSchema.index({ createdAt: 1 });
CareTemplateSchema.index({ status: 1 });
CareTemplateSchema.index({ "prediction.treatmentPlan": 1 });

const CareTemplate: Model<ICareTemplate> = mongoose.model<ICareTemplate>("CareTemplate", CareTemplateSchema);

export default CareTemplate; 