import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData16 = PlantAnalysis(
  assetImg: A.assets_lenbo_16,
  plantId: PlantId(
    commonName: 'Monstera Deliciosa',
    scientificName: 'Monstera deliciosa',
    family: 'Araceae',
    otherNames: ['Swiss Cheese Plant', 'Split-leaf Philodendron', 'Ceriman'],
    identificationConfidence: 0.98,
    funFact: 'In its native rainforest habitat, the holes in its leaves—called fenestrations—allow wind and light to pass through to the lower parts of the plant without tearing the foliage.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'The leaves are a vibrant, deep green with no signs of pests or spotting. The root system being handled looks firm and well-developed.',
    symptoms: [],
    overallImpression: 'Your Monstera is in excellent health and is clearly ready for its new home in that beautiful pot!',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Moist',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Outdoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Young',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '40+ years',
    maxHeight: '8-10 feet (indoors)',
  ),
  careGuide: CareGuide(
    summary: 'An iconic tropical climber that is surprisingly resilient and grows quickly when given enough space and light.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Use the \'soak and drain\' method—water until it runs out the bottom, then let the top 2 inches of soil dry out before watering again.',
      seasonalNote: 'Reduce watering frequency in winter when the plant\'s growth slows down.',
    ),
    light: LightGuide(
      idealCondition: 'Bright, filtered light is best for producing those signature leaf holes.',
      currentAssessment: 'The current outdoor shaded setting provides excellent dappled light.',
      adjustmentTip: 'If the leaves start to turn yellow without fenestrations, it might need a bit more light.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Once a month during the growing season.',
      recommendedType: 'Balanced liquid fertilizer diluted to half strength.',
      seasonalNote: 'Do not fertilize during the dormant winter months.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 85°F (18°C - 29°C)',
      tolerance: 'Protect from temperatures below 55°F to prevent leaf damage.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'High (60%+)',
      boostMethods: ['Group with other plants', 'Pebble tray with water', 'Regular misting'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Yellowing leaves',
      cause: 'Usually caused by overwatering or poor drainage.',
      prevention: 'Ensure the pot has drainage holes and the soil is chunky.',
      fix: 'Let the soil dry out completely and check for root rot.',
    ),
    CommonIssue(
      problem: 'Brown, crispy leaf edges',
      cause: 'Low humidity or underwatering.',
      prevention: 'Keep the plant away from air vents and heaters.',
      fix: 'Increase humidity and maintain a consistent watering schedule.',
    ),
  ],
  proTip: 'Give your Monstera a moss pole or trellis to climb; it will reward you with much larger leaves and more dramatic fenestrations!',
  plantPersonality: 'The \'Social Butterfly\' of the plant world, this Monstera loves to reach out and fill a room with its bold, artistic presence.',
  safety: SafetyInfo(
    toxicityNote: 'Contains calcium oxalate crystals which are toxic if ingested by pets.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep out of reach of cats and dogs to avoid oral irritation.',
  ),
);
