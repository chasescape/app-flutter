import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData14 = PlantAnalysis(
  assetImg: A.assets_lenbo_14,
  plantId: PlantId(
    commonName: 'Tea Plant',
    scientificName: 'Camellia sinensis',
    family: 'Theaceae',
    otherNames: ['Green Tea', 'Black Tea', 'Tea Camellia'],
    identificationConfidence: 0.95,
    funFact: 'Every true tea in the world—black, green, oolong, and white—comes from the leaves of this exact same species!',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.98,
    visualEvidence: 'Vibrant green leaves with sharp serrated edges and clear veins. Fresh, bright green new growth is visible at the terminal buds.',
    symptoms: [],
    overallImpression: 'Your tea plant looks exceptionally vigorous and well-hydrated, showing signs of active, healthy growth.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Outdoor Full Sun',
    soilMoistureVisual: 'Wet',
    potTypeGuess: 'In Ground',
    indoorOrOutdoor: 'Outdoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Young',
    difficultyLevel: 'Moderate',
    expectedLifespan: '30-50+ years',
    maxHeight: '6-10 feet',
  ),
  careGuide: CareGuide(
    summary: 'This evergreen shrub loves acidic soil and consistent moisture. It thrives in bright light and rewards patient growers with harvestable leaves.',
    watering: WateringGuide(
      frequency: 'Every 2-3 Days',
      method: 'Deep soak at the base of the plant.',
      seasonalNote: 'Keep soil consistently moist during the growing season; reduce slightly in winter.',
    ),
    light: LightGuide(
      idealCondition: 'Full sun to partial shade.',
      currentAssessment: 'Receiving excellent, high-intensity natural light.',
      adjustmentTip: 'In extremely hot climates, provide some afternoon shade to prevent leaf scorch.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Once a month during spring and summer.',
      recommendedType: 'Acid-loving plant fertilizer.',
      seasonalNote: 'Stop fertilizing in late fall to allow the plant to harden for winter.',
    ),
    temperature: TemperatureGuide(
      idealRange: '55°F - 85°F',
      tolerance: 'Can survive light frost but needs protection from hard freezes.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'High (70%+)',
      boostMethods: ['Regular misting', 'Grouping with other plants'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Root Rot',
      cause: 'Poor drainage or sitting in waterlogged soil.',
      prevention: 'Ensure soil is acidic and well-draining.',
      fix: 'Improve drainage and allow the top inch of soil to dry slightly before watering.',
    ),
    CommonIssue(
      problem: 'Leaf Scorch',
      cause: 'Intense direct sun during extreme heat waves.',
      prevention: 'Apply mulch to keep roots cool and moist.',
      fix: 'Provide temporary shade during peak afternoon heat.',
    ),
  ],
  proTip: 'For the highest quality tea, harvest only the \'flush\'—the top two leaves and the unopened leaf bud.',
  plantPersonality: 'A sophisticated and generous evergreen that offers a lifetime of harvests if you keep its roots happy and acidic.',
  safety: SafetyInfo(
    toxicityNote: 'Leaves contain caffeine, which is toxic to cats and dogs if ingested in significant amounts.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep away from curious pets who might nibble on the foliage.',
  ),
);
