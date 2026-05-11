import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData8 = PlantAnalysis(
  assetImg: A.assets_lenbo_8,
  plantId: PlantId(
    commonName: 'Boston Fern',
    scientificName: 'Nephrolepis exaltata',
    family: 'Lomariopsidaceae',
    otherNames: ['Sword Fern', 'Fishbone Fern'],
    identificationConfidence: 0.95,
    funFact: 'During the Victorian era, these ferns were so prized they were often displayed in specialized \'Wardian cases\'—the precursors to modern terrariums.',
  ),
  healthCheck: HealthCheck(
    status: 'Sub-Healthy',
    confidence: 0.85,
    visualEvidence: 'Lush green foliage overall, but visible browning and crisping on the tips of several lower fronds, likely due to low office humidity.',
    symptoms: ['Brown leaf tips', 'Dry, crispy leaflets'],
    overallImpression: 'Your fern looks vibrant and full, though it\'s showing early signs of thirst or dry air common in office environments.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Artificial Light',
    soilMoistureVisual: 'Unknown',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Mature',
    difficultyLevel: 'Moderate',
    expectedLifespan: '10+ years',
    maxHeight: '3 feet',
  ),
  careGuide: CareGuide(
    summary: 'Thrives in high humidity and consistent moisture. A classic choice for adding a lush, prehistoric feel to indoor spaces.',
    watering: WateringGuide(
      frequency: 'Every 2-3 Days',
      method: 'Water thoroughly until it drains from the bottom. Keep the soil consistently damp like a wrung-out sponge.',
      seasonalNote: 'Reduce watering slightly in winter, but never let the root ball dry out completely.',
    ),
    light: LightGuide(
      idealCondition: 'Bright Indirect Light',
      currentAssessment: 'Currently in artificial office light, which is sustainable but may lead to slower growth.',
      adjustmentTip: 'If possible, move it closer to a window with filtered light to encourage plusher, greener growth.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Monthly during spring and summer',
      recommendedType: 'Balanced liquid fertilizer diluted to half-strength',
      seasonalNote: 'Pause fertilizing during the winter months when growth naturally slows.',
    ),
    temperature: TemperatureGuide(
      idealRange: '60°F - 75°F',
      tolerance: 'Keep away from cold drafts and AC vents.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'High (50%+)',
      boostMethods: ['Place on a pebble tray with water', 'Mist the fronds daily', 'Use a small desk humidifier'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Browning leaf tips',
      cause: 'Dry air or inconsistent watering',
      prevention: 'Maintain high humidity and don\'t let soil dry out',
      fix: 'Trim brown tips with clean scissors and increase misting',
    ),
    CommonIssue(
      problem: 'Shedding leaflets',
      cause: 'Low light or soil drying out too much',
      prevention: 'Check soil moisture every two days',
      fix: 'Give the plant a deep soak and move to a brighter spot',
    ),
  ],
  proTip: 'Give your fern a \'spa day\' by placing it in the bathroom while you shower; the steam works wonders for its delicate fronds.',
  plantPersonality: 'A classic drama queen who loves the spotlight but will definitely let you know if she\'s feeling dry or neglected.',
  safety: SafetyInfo(
    toxicityNote: 'No known toxicity concerns.',
    petSafe: true,
    hasSensitiveContent: false,
    notes: 'Safe for both cats and dogs.',
  ),
);
