import mongoose, { Schema, Document } from 'mongoose';

export interface IPatient extends Document {
  auth: {
    email: string;
    phone?: string;
    password: string;
    status: 'active' | 'inactive' | 'pending';
  };
  medicalData: {
    age?: number;
    region?: string;
    cystSize?: number;
    ca125Level?: number;
    symptoms?: string;
    menopauseStage?: string;
    ultrasoundFeatures?: string;
    riskLevel: 'low' | 'medium' | 'high' | 'unknown';
    previousRecommendation?: string;
    careTemplate?: any;
  };
  createdAt: Date;
  updatedAt: Date;
}

const PatientSchema = new Schema<IPatient>({
  auth: {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    phone: {
      type: String,
      trim: true,
    },
    password: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      enum: ['active', 'inactive', 'pending'],
      default: 'active',
    },
  },
  medicalData: {
    age: {
      type: Number,
    },
    region: {
      type: String,
    },
    cystSize: {
      type: Number,
    },
    ca125Level: {
      type: Number,
    },
    symptoms: {
      type: String,
    },
    menopauseStage: {
      type: String,
      enum: ['Pre-menopausal', 'Peri-menopausal', 'Post-menopausal'],
    },
    ultrasoundFeatures: {
      type: String,
    },
    riskLevel: {
      type: String,
      enum: ['low', 'medium', 'high', 'unknown'],
      default: 'unknown',
    },
    previousRecommendation: {
      type: String,
    },
    careTemplate: {
      type: Schema.Types.Mixed,
    },
  },
}, {
  timestamps: true,
});

// Index for searching
PatientSchema.index({ 'medicalData.region': 1 });
PatientSchema.index({ 'medicalData.riskLevel': 1 });

export const Patient = mongoose.model<IPatient>('Patient', PatientSchema); 