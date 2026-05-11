import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData7 = PlantAnalysis(
  assetImg: A.assets_lenbo_7,
  plantId: PlantId(
    commonName: 'Sweet Basil',
    scientificName: 'Ocimum basilicum',
    family: 'Lamiaceae',
    otherNames: ['Genovese Basil', 'Great Basil', 'Saint-Joseph\'s-wort'],
    identificationConfidence: 0.98,
    funFact: 'Basil is a member of the mint family and its name is derived from the Greek word \'basileus\', meaning \'king\'!',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Vibrant green, turgid leaves with no visible spotting, yellowing, or pest damage. The stems are upright and vigorous.',
    symptoms: [],
    overallImpression: 'Your herb garden is absolutely thriving in this sunny urban spot!',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Outdoor Full Sun',
    soilMoistureVisual: 'Moist',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Outdoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Mature',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '1 year (Annual)',
    maxHeight: '12-24 inches',
  ),
  careGuide: CareGuide(
    summary: 'This basil loves the sun and regular harvesting. Keep the soil consistently moist but not soggy to maintain its lush growth.',
    watering: WateringGuide(
      frequency: 'Every 2-3 Days',
      method: 'Water at the base of the plant to keep the leaves dry and prevent fungal issues.',
      seasonalNote: 'During hot summer days on a balcony, you may need to water daily as pots dry out quickly.',
    ),
    light: LightGuide(
      idealCondition: 'At least 6-8 hours of direct sunlight daily.',
      currentAssessment: 'The current outdoor placement looks perfect for maximum growth.',
      adjustmentTip: 'If leaves begin to scorch or wilt excessively in the midday heat, provide a bit of afternoon shade.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Every 4 weeks during the growing season.',
      recommendedType: 'Balanced liquid organic fertilizer.',
      seasonalNote: 'Stop fertilizing in late autumn as growth slows down.',
    ),
    temperature: TemperatureGuide(
      idealRange: '70°F - 85°F (21°C - 29°C)',
      tolerance: 'Very sensitive to frost; bring indoors if temperatures drop below 50°F.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'Moderate (40-60%)',
      boostMethods: ['Group plants together', 'Ensure good airflow to prevent mildew'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Bolting (Flowering)',
      cause: 'Heat stress or natural life cycle completion.',
      prevention: 'Regularly pinch off the top leaves and any emerging flower buds.',
      fix: 'Cut back the flowering stems to encourage more leaf production.',
    ),
    CommonIssue(
      problem: 'Aphids',
      cause: 'Soft new growth attracts small green or black insects.',
      prevention: 'Check leaf undersides regularly.',
      fix: 'Wash them off with a strong stream of water or use insecticidal soap.',
    ),
    CommonIssue(
      problem: 'Root Rot',
      cause: 'Overwatering or poor drainage in the vertical planter.',
      prevention: 'Ensure the planter has drainage holes at the bottom.',
      fix: 'Reduce watering frequency and let the top inch of soil dry out.',
    ),
  ],
  proTip: 'Always harvest basil from the top down, cutting just above a pair of leaves. This encourages the plant to branch out and become bushier rather than tall and leggy.',
  plantPersonality: 'This sun-loving socialite brings a burst of fragrance to your balcony and is always ready to spice up your next meal.',
  safety: SafetyInfo(
    toxicityNote: 'No known toxicity concerns. Basil is generally safe for humans and pets.',
    petSafe: true,
    hasSensitiveContent: false,
    notes: '',
  ),
);
