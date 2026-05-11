import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData4 = PlantAnalysis(
  assetImg: A.assets_lenbo_4,
  plantId: PlantId(
    commonName: 'Monstera Deliciosa',
    scientificName: 'Monstera deliciosa',
    family: 'Araceae',
    otherNames: ['Swiss Cheese Plant', 'Mexican Breadfruit', 'Split-leaf Philodendron'],
    identificationConfidence: 0.98,
    funFact: 'In its native rainforest habitat, this plant produces a fruit that is said to taste like a delicious combination of pineapple, banana, and mango.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Vibrant green foliage with well-defined fenestrations and no visible signs of pests, yellowing, or browning.',
    symptoms: [],
    overallImpression: 'This is a stunningly healthy and well-established specimen showing excellent leaf development.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Moist',
    potTypeGuess: 'In Ground',
    indoorOrOutdoor: 'Outdoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Mature',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '40+ years',
    maxHeight: '10-15 feet',
  ),
  careGuide: CareGuide(
    summary: 'This tropical beauty is surprisingly hardy and thrives when given plenty of bright, filtered light and a regular watering schedule.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Thoroughly soak the soil until water drains out, then allow the top 2 inches of soil to dry before watering again.',
      seasonalNote: 'Reduce watering frequency during winter months when growth slows down.',
    ),
    light: LightGuide(
      idealCondition: 'Bright, indirect sunlight is perfect to encourage large leaves and holes.',
      currentAssessment: 'The plant appears to be receiving ideal dappled light, resulting in healthy fenestrations.',
      adjustmentTip: 'If leaves start to yellow without holes, move it to a brighter spot away from direct afternoon sun.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Every 4 weeks during Spring and Summer.',
      recommendedType: 'Balanced liquid fertilizer diluted to half strength.',
      seasonalNote: 'Stop fertilizing during the dormant winter period.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 85°F',
      tolerance: 'Keep above 50°F; it is not frost-tolerant.',
    ),
    humidity: HumidityGuide(
      idealLevel: '60% or higher',
      boostMethods: ['Regular misting', 'Use a pebble tray', 'Group with other plants'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Yellowing Lower Leaves',
      cause: 'Usually a sign of overwatering or poor drainage.',
      prevention: 'Ensure the pot has drainage holes and check soil moisture before watering.',
      fix: 'Allow the soil to dry out completely and reduce watering frequency.',
    ),
    CommonIssue(
      problem: 'Brown, Crispy Leaf Edges',
      cause: 'Low humidity or underwatering.',
      prevention: 'Maintain consistent humidity and don\'t let the soil go bone-dry for too long.',
      fix: 'Increase humidity with a humidifier and trim away the dead edges with sterile shears.',
    ),
    CommonIssue(
      problem: 'Lack of Leaf Holes',
      cause: 'Insufficient light or the plant is too young.',
      prevention: 'Place in a spot with plenty of bright, indirect light.',
      fix: 'Move the plant closer to a window or provide supplemental grow lights.',
    ),
  ],
  proTip: 'Gently wipe the large leaves with a damp cloth every few weeks to remove dust; this helps the plant breathe and absorb more light for growth.',
  plantPersonality: 'The ultimate \'it\' plant, this Monstera is a confident showstopper that brings a bold, tropical vibe to any space.',
  safety: SafetyInfo(
    toxicityNote: 'Contains calcium oxalate crystals which are toxic to pets and humans if ingested.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep out of reach of curious cats, dogs, and small children.',
  ),
);
