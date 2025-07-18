import { Document } from "mongoose";

export interface ISymptom extends Document {
  _id: string;
  userId: string;
  symptoms: {
    bloating: boolean;
    pelvicPain: boolean;
    irregularPeriods: boolean;
    heavyBleeding: boolean;
    fatigue: boolean;
    moodSwings: boolean;
    breastTenderness: boolean;
    backPain: boolean;
    nausea: boolean;
    weightGain: boolean;
    otherSymptoms?: string;
  };
  severity: "Mild" | "Moderate" | "Severe";
  duration: string; // e.g., "2 days", "1 week", "2 weeks"
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateSymptomRequest {
  symptoms: {
    bloating: boolean;
    pelvicPain: boolean;
    irregularPeriods: boolean;
    heavyBleeding: boolean;
    fatigue: boolean;
    moodSwings: boolean;
    breastTenderness: boolean;
    backPain: boolean;
    nausea: boolean;
    weightGain: boolean;
    otherSymptoms?: string;
  };
  severity: "Mild" | "Moderate" | "Severe";
  duration: string;
  notes?: string;
}

export interface UpdateSymptomRequest {
  symptoms?: {
    bloating?: boolean;
    pelvicPain?: boolean;
    irregularPeriods?: boolean;
    heavyBleeding?: boolean;
    fatigue?: boolean;
    moodSwings?: boolean;
    breastTenderness?: boolean;
    backPain?: boolean;
    nausea?: boolean;
    weightGain?: boolean;
    otherSymptoms?: string;
  };
  severity?: "Mild" | "Moderate" | "Severe";
  duration?: string;
  notes?: string;
} 