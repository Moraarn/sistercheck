import Symptom from "./model";
import { ISymptom, CreateSymptomRequest, UpdateSymptomRequest } from "./type";
import { Types } from "mongoose";
import { AppError } from "../../utils/api.errors";
import { CareTemplateService } from "../care-template/service";

export class SymptomService {
  private careTemplateService: CareTemplateService;

  constructor() {
    this.careTemplateService = new CareTemplateService();
  }

  /**
   * Convert symptoms to AI model format
   */
  private convertSymptomsToAIFormat(symptoms: any): string {
    const symptomList = [];
    
    if (symptoms.bloating) symptomList.push('Bloating');
    if (symptoms.pelvicPain) symptomList.push('Pelvic Pain');
    if (symptoms.irregularPeriods) symptomList.push('Irregular Periods');
    if (symptoms.heavyBleeding) symptomList.push('Heavy Bleeding');
    if (symptoms.fatigue) symptomList.push('Fatigue');
    if (symptoms.moodSwings) symptomList.push('Mood Swings');
    if (symptoms.breastTenderness) symptomList.push('Breast Tenderness');
    if (symptoms.backPain) symptomList.push('Back Pain');
    if (symptoms.nausea) symptomList.push('Nausea');
    if (symptoms.weightGain) symptomList.push('Weight Gain');
    
    return symptomList.join(', ') || 'None';
  }

  /**
   * Create a new symptom entry and generate care template
   */
  async createSymptom(symptomData: CreateSymptomRequest & { userId: string }) {
    const symptom = await Symptom.create(symptomData);
    const symptomObject = symptom.toObject();

    try {
      // Automatically create a care template using AI prediction
      const patientDataForAI = {
        age: 30, // Default age - could be enhanced to get from user profile
        menopauseStage: 'Pre-menopausal', // Default - could be enhanced
        cystSize: 0, // Default - could be enhanced with ultrasound data
        cystGrowth: 0, // Default - could be enhanced
        fca125Level: 0, // Default - could be enhanced with blood test data
        ultrasoundFeatures: 'Normal', // Default - could be enhanced
        reportedSymptoms: this.convertSymptomsToAIFormat(symptomData.symptoms)
      };

      await this.careTemplateService.createCareTemplate({
        userId: symptomData.userId,
        symptomId: symptomObject._id.toString(),
        patientData: patientDataForAI
      });

      console.log(`Care template created for symptom ID: ${symptomObject._id}`);
    } catch (error) {
      console.error('Failed to create care template:', error);
      // Don't fail the symptom creation if care template creation fails
    }

    return symptomObject;
  }

  /**
   * Get symptom by ID
   */
  async getSymptomById(symptomId: string | Types.ObjectId) {
    return await Symptom.findById(symptomId).lean();
  }

  /**
   * Get user's latest symptom entry
   */
  async getUserLatestSymptom(userId: string) {
    return await Symptom.findOne({ userId })
      .sort({ createdAt: -1 })
      .lean();
  }

  /**
   * Get all symptoms for a user
   */
  async getUserSymptoms(userId: string, query: any) {
    const apiFeature = new (
      await import("../../utils/api.features")
    ).ApiFeatures(Symptom.find({ userId }), query)
      .pagination()
      .fields()
      .sort();

    return await apiFeature.getPaginatedData<[]>();
  }

  /**
   * Update a symptom entry
   */
  async updateSymptom(symptomId: string, updateData: UpdateSymptomRequest) {
    const symptom = await Symptom.findByIdAndUpdate(
      symptomId,
      updateData,
      { new: true, runValidators: true }
    ).lean();

    if (!symptom) {
      throw new AppError(404, "Symptom not found");
    }

    return symptom;
  }

  /**
   * Delete a symptom entry
   */
  async deleteSymptom(symptomId: string) {
    const symptom = await Symptom.findByIdAndDelete(symptomId);
    
    if (!symptom) {
      throw new AppError(404, "Symptom not found");
    }

    return { message: "Symptom deleted successfully" };
  }

  /**
   * Get symptom statistics for a user
   */
  async getSymptomStats(userId: string) {
    const stats = await Symptom.aggregate([
      { $match: { userId } },
      {
        $group: {
          _id: null,
          totalEntries: { $sum: 1 },
          averageSeverity: {
            $avg: {
              $cond: [
                { $eq: ["$severity", "Mild"] },
                1,
                { $cond: [{ $eq: ["$severity", "Moderate"] }, 2, 3] }
              ]
            }
          },
          mostCommonSymptoms: {
            $push: {
              bloating: "$symptoms.bloating",
              pelvicPain: "$symptoms.pelvicPain",
              irregularPeriods: "$symptoms.irregularPeriods",
              heavyBleeding: "$symptoms.heavyBleeding",
              fatigue: "$symptoms.fatigue",
              moodSwings: "$symptoms.moodSwings",
              breastTenderness: "$symptoms.breastTenderness",
              backPain: "$symptoms.backPain",
              nausea: "$symptoms.nausea",
              weightGain: "$symptoms.weightGain"
            }
          }
        }
      }
    ]);

    if (stats.length === 0) {
      return {
        totalEntries: 0,
        averageSeverity: 0,
        mostCommonSymptoms: {}
      };
    }

    const stat = stats[0];
    const symptomCounts = {
      bloating: 0,
      pelvicPain: 0,
      irregularPeriods: 0,
      heavyBleeding: 0,
      fatigue: 0,
      moodSwings: 0,
      breastTenderness: 0,
      backPain: 0,
      nausea: 0,
      weightGain: 0
    };

    stat.mostCommonSymptoms.forEach((entry: any) => {
      Object.keys(entry).forEach(key => {
        if (entry[key]) {
          symptomCounts[key as keyof typeof symptomCounts]++;
        }
      });
    });

    return {
      totalEntries: stat.totalEntries,
      averageSeverity: Math.round(stat.averageSeverity * 100) / 100,
      mostCommonSymptoms: symptomCounts
    };
  }

  /**
   * Get symptoms by severity level
   */
  async getSymptomsBySeverity(userId: string, severity: "Mild" | "Moderate" | "Severe") {
    return await Symptom.find({ userId, severity })
      .sort({ createdAt: -1 })
      .lean();
  }

  /**
   * Get recent symptoms (last 30 days)
   */
  async getRecentSymptoms(userId: string) {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    return await Symptom.find({
      userId,
      createdAt: { $gte: thirtyDaysAgo }
    })
      .sort({ createdAt: -1 })
      .lean();
  }
} 