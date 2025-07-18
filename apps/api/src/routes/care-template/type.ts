export interface ICareTemplate {
  _id?: string;
  userId: string;
  symptomId?: string;
  riskAssessmentId?: string;
  patientData: {
    age?: number;
    menopauseStage?: string;
    cystSize?: number;
    cystGrowth?: number;
    fca125Level?: number;
    ultrasoundFeatures?: string;
    reportedSymptoms?: string;
  };
  prediction: {
    treatmentPlan: string;
    confidence: number;
    probabilities?: Map<string, number>;
  };
  carePlan: {
    costInfo: {
      service?: string;
      baseCost?: number;
      outOfPocket?: number;
    };
    inventoryInfo: {
      item?: string;
      availableStock?: number;
    };
    recommendations: string[];
    nextSteps: string[];
  };
  status: "pending" | "approved" | "in_progress" | "completed";
  createdAt?: Date;
  updatedAt?: Date;
}

export interface CreateCareTemplateRequest {
  symptomId?: string;
  riskAssessmentId?: string;
  patientData: {
    age?: number;
    menopauseStage?: string;
    cystSize?: number;
    cystGrowth?: number;
    fca125Level?: number;
    ultrasoundFeatures?: string;
    reportedSymptoms?: string;
  };
}

export interface UpdateCareTemplateRequest {
  status?: "pending" | "approved" | "in_progress" | "completed";
  carePlan?: {
    recommendations?: string[];
    nextSteps?: string[];
  };
} 