import RiskAssessment from "./model";
import { IRiskAssessment } from "./type";
import { Types } from "mongoose";
import { AppError } from "../../utils/api.errors";
import { CareTemplateService } from "../care-template/service";

export class RiskAssessmentService {
  private careTemplateService: CareTemplateService;

  constructor() {
    this.careTemplateService = new CareTemplateService();
  }

  /**
   * Convert risk assessment answers to AI model format
   */
  private convertAnswersToAIFormat(answers: any): string {
    const symptomList = [];
    
    if (answers.bloating) symptomList.push('Bloating');
    if (answers.pelvicPain) symptomList.push('Pelvic Pain');
    if (answers.irregularPeriods) symptomList.push('Irregular Periods');
    
    return symptomList.join(', ') || 'None';
  }

  /**
   * Create a new risk assessment and generate care template
   */
  async createRiskAssessment(assessmentData: Partial<IRiskAssessment>) {
    // Calculate risk level and score based on answers
    const { answers } = assessmentData;
    const score = this.calculateRiskScore(answers);
    const riskLevel = this.determineRiskLevel(score);
    const recommendations = this.generateRecommendations(riskLevel, answers);

    const assessment = await RiskAssessment.create({
      ...assessmentData,
      score,
      riskLevel,
      recommendations
    });

    const assessmentObject = assessment.toObject();

    try {
      // Automatically create a care template using AI prediction
      const patientDataForAI = {
        age: 30, // Default age - could be enhanced to get from user profile
        menopauseStage: 'Pre-menopausal', // Default - could be enhanced
        cystSize: 0, // Default - could be enhanced with ultrasound data
        cystGrowth: 0, // Default - could be enhanced
        fca125Level: 0, // Default - could be enhanced with blood test data
        ultrasoundFeatures: 'Normal', // Default - could be enhanced
        reportedSymptoms: this.convertAnswersToAIFormat(answers)
      };

      await this.careTemplateService.createCareTemplate({
        userId: assessmentData.userId!,
        riskAssessmentId: assessmentObject._id.toString(),
        patientData: patientDataForAI
      });

      console.log(`Care template created for risk assessment ID: ${assessmentObject._id}`);
    } catch (error) {
      console.error('Failed to create care template:', error);
      // Don't fail the risk assessment creation if care template creation fails
    }

    return assessmentObject;
  }

  /**
   * Get risk assessment by ID
   */
  async getRiskAssessmentById(assessmentId: string | Types.ObjectId) {
    return await RiskAssessment.findById(assessmentId).lean();
  }

  /**
   * Get user's latest risk assessment
   */
  async getUserLatestAssessment(userId: string) {
    return await RiskAssessment.findOne({ userId })
      .sort({ createdAt: -1 })
      .lean();
  }

  /**
   * Get all risk assessments for a user
   */
  async getUserAssessments(userId: string, query: any) {
    const apiFeature = new (
      await import("../../utils/api.features")
    ).ApiFeatures(RiskAssessment.find({ userId }), query)
      .pagination()
      .fields()
      .sort();

    return await apiFeature.getPaginatedData<[]>();
  }

  /**
   * Calculate risk score based on answers
   */
  private calculateRiskScore(answers: any): number {
    let score = 0;
    
    if (answers.bloating) score += 2;
    if (answers.pelvicPain) score += 3;
    if (answers.irregularPeriods) score += 2;
    
    // Mood scoring
    if (answers.mood === 'stressed') score += 1;
    if (answers.mood === 'anxious') score += 2;
    if (answers.mood === 'depressed') score += 3;
    
    // Exercise scoring
    if (answers.exercise === 'none') score += 2;
    if (answers.exercise === 'light') score += 1;
    if (answers.exercise === 'moderate') score += 0;
    if (answers.exercise === 'intense') score += 0;
    
    return score;
  }

  /**
   * Determine risk level based on score
   */
  private determineRiskLevel(score: number): "Low" | "Moderate" | "High" {
    if (score <= 3) return "Low";
    if (score <= 7) return "Moderate";
    return "High";
  }

  /**
   * Generate recommendations based on risk level and answers
   */
  private generateRecommendations(riskLevel: string, answers: any): string[] {
    const recommendations: string[] = [];
    
    if (riskLevel === "Low") {
      recommendations.push("Continue maintaining a healthy lifestyle");
      recommendations.push("Schedule regular check-ups with your healthcare provider");
    } else if (riskLevel === "Moderate") {
      recommendations.push("Consider scheduling a consultation with a healthcare provider");
      recommendations.push("Monitor your symptoms and keep a health diary");
      if (answers.exercise === 'none' || answers.exercise === 'light') {
        recommendations.push("Try to incorporate moderate exercise into your routine");
      }
    } else {
      recommendations.push("Schedule an appointment with a healthcare provider as soon as possible");
      recommendations.push("Consider reaching out to a peer sister for support");
      recommendations.push("Keep detailed records of your symptoms");
    }
    
    return recommendations;
  }
} 