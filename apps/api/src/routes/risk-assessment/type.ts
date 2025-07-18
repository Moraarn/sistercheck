import { Document } from "mongoose";

export interface IRiskAssessment extends Document {
  _id: string;
  userId: string;
  answers: {
    bloating: boolean;
    pelvicPain: boolean;
    irregularPeriods: boolean;
    mood: string;
    exercise: string;
  };
  riskLevel: "Low" | "Moderate" | "High";
  score: number;
  recommendations: string[];
  createdAt: Date;
  updatedAt: Date;
} 