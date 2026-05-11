import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData3 = PlantAnalysis(
  assetImg: A.assets_lenbo_3,
  plantId: PlantId(
    commonName: 'Golden Pothos',
    scientificName: 'Epipremnum aureum',
    family: 'Araceae',
    otherNames: ['Devil\'s Ivy', 'Money Plant', 'Silver Vine'],
    identificationConfidence: 0.98,
    funFact: 'It is nicknamed \'Devil\'s Ivy\' because it is nearly impossible to kill and stays green even when kept in near-total darkness.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Vibrant green and yellow variegated leaves, long lush vines with no visible spots or wilting.',
    symptoms: [],
    overallImpression: 'This Pothos is thriving beautifully with impressive vine length and healthy variegation.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Unknown',
    potTypeGuess: 'Hanging',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Mature',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '10+ years',
    maxHeight: '20-40 feet (vine length)',
  ),
  careGuide: CareGuide(
    summary: 'An incredibly resilient trailing plant that adapts to most indoor environments while cleaning the air.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Soak-and-drain; water until it flows from drainage holes, then discard excess water.',
      seasonalNote: 'Reduce watering in winter, allowing the soil to dry out more between sessions.',
    ),
    light: LightGuide(
      idealCondition: 'Bright, indirect light to maintain the beautiful yellow variegation.',
      currentAssessment: 'The plant is receiving excellent light, evidenced by the strong yellow patterns.',
      adjustmentTip: 'If new leaves are solid green, move it closer to a window.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Monthly during spring and summer.',
      recommendedType: 'Balanced liquid fertilizer diluted to half strength.',
      seasonalNote: 'Do not fertilize during the dormant winter months.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 85°F (18°C - 29°C)',
      tolerance: 'Avoid temperatures below 50°F (10°C) to prevent leaf damage.',
    ),
    humidity: HumidityGuide(
      idealLevel: '50-70%',
      boostMethods: ['Misting leaves', 'Grouping with other plants', 'Pebble tray'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Yellowing Leaves',
      cause: 'Usually a sign of overwatering or root rot.',
      prevention: 'Ensure the top inch of soil is dry before watering again.',
      fix: 'Check drainage and allow the soil to dry out completely.',
    ),
    CommonIssue(
      problem: 'Brown Leaf Tips',
      cause: 'Low humidity or accumulation of salts from tap water.',
      prevention: 'Mist regularly and use filtered water if possible.',
      fix: 'Trim the brown tips and increase humidity around the plant.',
    ),
    CommonIssue(
      problem: 'Leggy Vines',
      cause: 'Insufficient light causing the plant to \'stretch\'.',
      prevention: 'Provide bright, indirect light.',
      fix: 'Prune the long, thin vines to encourage bushier growth.',
    ),
  ],
  proTip: 'To get massive leaves, provide a moss pole; Pothos leaves naturally grow larger when the plant is allowed to climb upward.',
  plantPersonality: 'This easy-going trailing vine is the ultimate roommate—low maintenance, adaptable, and always adding a touch of elegance to your home.',
  safety: SafetyInfo(
    toxicityNote: 'Contains calcium oxalate crystals which are toxic to pets and humans if ingested.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep out of reach of cats and dogs as it can cause oral irritation and swelling.',
  ),
);
