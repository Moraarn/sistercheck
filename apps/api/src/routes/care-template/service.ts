import CareTemplate from "./model";
import { ICareTemplate, CreateCareTemplateRequest, UpdateCareTemplateRequest } from "./type";
import { Types } from "mongoose";
import { AppError } from "../../utils/api.errors";
import axios from "axios";

export class CareTemplateService {
  private pythonApiUrl: string;

  constructor() {
    this.pythonApiUrl = process.env.PYTHON_API_URL || "http://localhost:5000";
  }

  /**
   * Call Python API to get prediction
   */
  private async getPrediction(patientData: any) {
    try {
      const response = await axios.post(`${this.pythonApiUrl}/care-template`, patientData, {
        timeout: 30000, // 30 seconds timeout
        headers: {
          'Content-Type': 'application/json'
        }
      });

      if (response.data.success) {
        return response.data;
      } else {
        throw new Error(response.data.error || 'Prediction failed');
      }
    } catch (error) {
      console.error('Error calling Python API:', error);
      throw new AppError(500, 'Failed to get prediction from AI model');
    }
  }

  /**
   * Create a new care template with AI prediction
   */
  async createCareTemplate(templateData: CreateCareTemplateRequest & { userId: string }) {
    try {
      // Prepare patient data for the AI model
      const patientDataForAI = {
        Age: templateData.patientData.age || 30,
        'Menopause Stage': templateData.patientData.menopauseStage || 'Pre-menopausal',
        'SI Cyst Size cm': templateData.patientData.cystSize || 0,
        'Cyst Growth': templateData.patientData.cystGrowth || 0,
        'fca 125 Level': templateData.patientData.fca125Level || 0,
        'Ultrasound Fe': templateData.patientData.ultrasoundFeatures || 'Normal',
        'Reported Sym': templateData.patientData.reportedSymptoms || 'None'
      };

      // Get prediction from Python API
      const predictionResult = await this.getPrediction(patientDataForAI);

      // Create care template with prediction results
      const careTemplateData = {
        userId: templateData.userId,
        symptomId: templateData.symptomId,
        riskAssessmentId: templateData.riskAssessmentId,
        patientData: templateData.patientData,
        prediction: {
          treatmentPlan: predictionResult.prediction,
          confidence: predictionResult.confidence,
          probabilities: predictionResult.probabilities
        },
        carePlan: {
          costInfo: predictionResult.costInfo,
          inventoryInfo: predictionResult.inventoryInfo,
          recommendations: this.generateRecommendations(predictionResult.prediction),
          nextSteps: this.generateNextSteps(predictionResult.prediction)
        },
        status: "pending" as const
      };

      const careTemplate = await CareTemplate.create(careTemplateData);
      return careTemplate.toObject();
    } catch (error) {
      console.error('Error creating care template:', error);
      throw error;
    }
  }

  /**
   * Generate recommendations based on treatment plan
   */
  private generateRecommendations(treatmentPlan: string): string[] {
    const recommendations: { [key: string]: string[] } = {
      'Surgery': [
        'Schedule consultation with gynecological surgeon',
        'Prepare for pre-operative tests',
        'Arrange post-operative care support',
        'Consider taking time off work for recovery'
      ],
      'Medication': [
        'Follow prescribed medication schedule strictly',
        'Monitor for any side effects',
        'Attend follow-up appointments',
        'Maintain symptom diary'
      ],
      'Observation': [
        'Schedule regular monitoring appointments',
        'Track symptoms and changes',
        'Maintain healthy lifestyle habits',
        'Report any new or worsening symptoms'
      ],
      'Referral': [
        'Contact the referred specialist',
        'Prepare medical history and current symptoms',
        'Bring all relevant test results',
        'Ask questions about treatment options'
      ]
    };

    return recommendations[treatmentPlan] || [
      'Follow up with healthcare provider',
      'Monitor symptoms regularly',
      'Maintain healthy lifestyle'
    ];
  }

  /**
   * Generate next steps based on treatment plan
   */
  private generateNextSteps(treatmentPlan: string): string[] {
    const nextSteps: { [key: string]: string[] } = {
      'Surgery': [
        'Complete pre-operative assessment',
        'Schedule surgery date',
        'Prepare for hospital stay',
        'Arrange post-operative support'
      ],
      'Medication': [
        'Start medication as prescribed',
        'Schedule follow-up in 2 weeks',
        'Monitor symptoms daily',
        'Report any adverse effects'
      ],
      'Observation': [
        'Schedule next appointment in 1 month',
        'Continue symptom tracking',
        'Maintain regular exercise routine',
        'Follow up if symptoms worsen'
      ],
      'Referral': [
        'Contact specialist within 1 week',
        'Prepare for specialist consultation',
        'Gather all medical records',
        'Follow specialist recommendations'
      ]
    };

    return nextSteps[treatmentPlan] || [
      'Schedule follow-up appointment',
      'Continue monitoring symptoms',
      'Contact healthcare provider if needed'
    ];
  }

  /**
   * Get care template by ID
   */
  async getCareTemplateById(templateId: string | Types.ObjectId) {
    return await CareTemplate.findById(templateId).lean();
  }

  /**
   * Get user's latest care template
   */
  async getUserLatestCareTemplate(userId: string) {
    return await CareTemplate.findOne({ userId })
      .sort({ createdAt: -1 })
      .lean();
  }

  /**
   * Get all care templates for a user
   */
  async getUserCareTemplates(userId: string, query: any) {
    const apiFeature = new (
      await import("../../utils/api.features")
    ).ApiFeatures(CareTemplate.find({ userId }), query)
      .pagination()
      .fields()
      .sort();

    return await apiFeature.getPaginatedData<[]>();
  }

  /**
   * Update a care template
   */
  async updateCareTemplate(templateId: string, updateData: UpdateCareTemplateRequest) {
    const careTemplate = await CareTemplate.findByIdAndUpdate(
      templateId,
      updateData,
      { new: true, runValidators: true }
    ).lean();

    if (!careTemplate) {
      throw new AppError(404, "Care template not found");
    }

    return careTemplate;
  }

  /**
   * Delete a care template
   */
  async deleteCareTemplate(templateId: string) {
    const careTemplate = await CareTemplate.findByIdAndDelete(templateId);
    
    if (!careTemplate) {
      throw new AppError(404, "Care template not found");
    }

    return { message: "Care template deleted successfully" };
  }

  /**
   * Get care templates by status
   */
  async getCareTemplatesByStatus(userId: string, status: "pending" | "approved" | "in_progress" | "completed") {
    return await CareTemplate.find({ userId, status })
      .sort({ createdAt: -1 })
      .lean();
  }

  /**
   * Get care template statistics for a user
   */
  async getCareTemplateStats(userId: string) {
    const stats = await CareTemplate.aggregate([
      { $match: { userId } },
      {
        $group: {
          _id: null,
          totalTemplates: { $sum: 1 },
          pendingCount: {
            $sum: { $cond: [{ $eq: ["$status", "pending"] }, 1, 0] }
          },
          approvedCount: {
            $sum: { $cond: [{ $eq: ["$status", "approved"] }, 1, 0] }
          },
          inProgressCount: {
            $sum: { $cond: [{ $eq: ["$status", "in_progress"] }, 1, 0] }
          },
          completedCount: {
            $sum: { $cond: [{ $eq: ["$status", "completed"] }, 1, 0] }
          },
          treatmentPlans: {
            $push: "$prediction.treatmentPlan"
          }
        }
      }
    ]);

    if (stats.length === 0) {
      return {
        totalTemplates: 0,
        pendingCount: 0,
        approvedCount: 0,
        inProgressCount: 0,
        completedCount: 0,
        treatmentPlanDistribution: {}
      };
    }

    const stat = stats[0];
    const treatmentPlanCounts: { [key: string]: number } = {};
    
    stat.treatmentPlans.forEach((plan: string) => {
      treatmentPlanCounts[plan] = (treatmentPlanCounts[plan] || 0) + 1;
    });

    return {
      totalTemplates: stat.totalTemplates,
      pendingCount: stat.pendingCount,
      approvedCount: stat.approvedCount,
      inProgressCount: stat.inProgressCount,
      completedCount: stat.completedCount,
      treatmentPlanDistribution: treatmentPlanCounts
    };
  }
} 