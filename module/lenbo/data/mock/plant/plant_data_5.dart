import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData5 = PlantAnalysis(
  assetImg: A.assets_lenbo_5,
  plantId: PlantId(
    commonName: 'Monstera Deliciosa',
    scientificName: 'Monstera deliciosa',
    family: 'Araceae',
    otherNames: ['Swiss Cheese Plant', 'Split-leaf Philodendron', 'Mexican Breadfruit'],
    identificationConfidence: 0.92,
    funFact: 'In its native tropical habitat, the Monstera produces a delicious fruit that tastes like a mix of pineapple, banana, and strawberry.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.85,
    visualEvidence: 'The leaf held in focus shows a deep, vibrant green color with clear, healthy venation and no visible signs of pests, spots, or browning.',
    symptoms: [],
    overallImpression: 'Your plant looks incredibly vibrant and well-hydrated, showing great vitality in its foliage.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Low Light',
    soilMoistureVisual: 'Unknown',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Mature',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '40+ years',
    maxHeight: '10-15 feet indoors',
  ),
  careGuide: CareGuide(
    summary: 'A quintessential tropical climber known for its iconic perforated leaves and easy-going nature.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Water thoroughly until it drains from the bottom, then allow the top 2 inches of soil to dry out before watering again.',
      seasonalNote: 'During winter months, growth slows down, so you can wait longer between waterings.',
    ),
    light: LightGuide(
      idealCondition: 'Bright Indirect Light',
      currentAssessment: 'The current environment appears quite dark, lit mostly by artificial screen light.',
      adjustmentTip: 'Move your plant closer to a north or east-facing window to encourage the development of those iconic leaf holes (fenestrations).',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Monthly during Spring and Summer',
      recommendedType: 'Balanced liquid fertilizer diluted to half-strength.',
      seasonalNote: 'Stop fertilizing in the winter to allow the plant its natural rest period.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 85°F (18°C - 29°C)',
      tolerance: 'Keep away from cold drafts and air conditioning vents.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'High (60%+)',
      boostMethods: ['Place a humidifier nearby', 'Group with other plants', 'Use a pebble tray with water'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Yellowing Lower Leaves',
      cause: 'Usually a sign of overwatering or poor drainage.',
      prevention: 'Ensure the pot has drainage holes and the soil isn\'t staying soggy.',
      fix: 'Let the soil dry out completely and check that the roots aren\'t sitting in water.',
    ),
    CommonIssue(
      problem: 'Brown, Crispy Leaf Edges',
      cause: 'Lack of humidity or underwatering.',
      prevention: 'Keep the plant away from heaters and maintain consistent moisture.',
      fix: 'Increase humidity around the plant and trim the brown edges with clean scissors.',
    ),
  ],
  proTip: 'Wipe the large leaves with a damp cloth every few weeks to remove dust; this helps the plant \'breathe\' and photosynthesize much better!',
  plantPersonality: 'The ultimate \'main character\' of the plant world, this bold climber is as dramatic as it is resilient, rewarding your care with massive, artistic leaves.',
  safety: SafetyInfo(
    toxicityNote: 'Contains calcium oxalate crystals which are toxic to cats and dogs if ingested.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep out of reach of curious pets and small children.',
  ),
);
