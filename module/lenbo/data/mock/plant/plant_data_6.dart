import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData6 = PlantAnalysis(
  assetImg: A.assets_lenbo_6,
  plantId: PlantId(
    commonName: 'Peace Lily',
    scientificName: 'Spathiphyllum',
    family: 'Araceae',
    otherNames: ['Mauna Loa', 'White Sails'],
    identificationConfidence: 0.92,
    funFact: 'Peace Lilies are not true lilies; they are actually related to Philodendrons and can even help clean indoor air by removing toxins.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Deep green, upright foliage with no visible spotting, yellowing, or drooping across the collection.',
    symptoms: [],
    overallImpression: 'Your indoor garden looks wonderfully vibrant and well-maintained!',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Moist',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Mature',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '10+ years',
    maxHeight: '1-4 feet',
  ),
  careGuide: CareGuide(
    summary: 'An elegant, low-maintenance choice that thrives in moderate light and signals its water needs clearly.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Water thoroughly until it drains from the bottom. These plants are famous for \'fainting\' when thirsty.',
      seasonalNote: 'Allow the top inch of soil to dry out more between waterings during the winter.',
    ),
    light: LightGuide(
      idealCondition: 'Prefers bright, filtered light but is highly adaptable to lower light conditions.',
      currentAssessment: 'The current shelf placement provides excellent ambient light for lush growth.',
      adjustmentTip: 'If leaves turn pale or yellow, it may be getting too much direct sun.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Every 6 weeks during the growing season.',
      recommendedType: 'Balanced liquid fertilizer diluted to half-strength.',
      seasonalNote: 'Stop fertilizing in late autumn and winter months.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 85°F (18°C - 29°C)',
      tolerance: 'Keep away from cold drafts and temperatures below 55°F.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'High (50%+)',
      boostMethods: ['Misting leaves regularly', 'Grouping plants together', 'Using a pebble tray'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Brown leaf tips',
      cause: 'Tap water chemicals or low humidity.',
      prevention: 'Use filtered water and increase humidity levels.',
      fix: 'Trim brown tips with clean scissors and switch to distilled water.',
    ),
    CommonIssue(
      problem: 'Yellowing lower leaves',
      cause: 'Natural aging or slight overwatering.',
      prevention: 'Ensure well-draining soil and don\'t let it sit in water.',
      fix: 'Prune old leaves at the base and check soil moisture before watering.',
    ),
  ],
  proTip: 'Wipe the leaves with a damp cloth every few weeks; removing dust allows the plant to breathe and photosynthesize much better.',
  plantPersonality: 'This elegant beauty is a communicative companion that clearly signals its needs, making it a perfect partner for new plant parents.',
  safety: SafetyInfo(
    toxicityNote: 'Contains calcium oxalate crystals which can cause irritation if ingested.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep out of reach of curious cats, dogs, and small children.',
  ),
);
