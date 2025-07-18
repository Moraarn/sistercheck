import mongoose, { Schema, Model } from "mongoose";
import { ISymptom } from "./type";

const SymptomSchema: Schema<ISymptom> = new Schema(
  {
    userId: { type: String, required: true },
    symptoms: {
      bloating: { type: Boolean, required: true },
      pelvicPain: { type: Boolean, required: true },
      irregularPeriods: { type: Boolean, required: true },
      heavyBleeding: { type: Boolean, required: true },
      fatigue: { type: Boolean, required: true },
      moodSwings: { type: Boolean, required: true },
      breastTenderness: { type: Boolean, required: true },
      backPain: { type: Boolean, required: true },
      nausea: { type: Boolean, required: true },
      weightGain: { type: Boolean, required: true },
      otherSymptoms: { type: String, default: "" }
    },
    severity: { type: String, enum: ["Mild", "Moderate", "Severe"], required: true },
    duration: { type: String, required: true },
    notes: { type: String, default: "" }
  },
  { timestamps: true }
);

// Create indexes
SymptomSchema.index({ userId: 1 });
SymptomSchema.index({ createdAt: 1 });
SymptomSchema.index({ severity: 1 });

const Symptom: Model<ISymptom> = mongoose.model<ISymptom>("Symptom", SymptomSchema);

export default Symptom; 