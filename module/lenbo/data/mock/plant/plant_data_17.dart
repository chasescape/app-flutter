import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData17 = PlantAnalysis(
  assetImg: A.assets_lenbo_17,
  plantId: PlantId(
    commonName: 'Okra',
    scientificName: 'Abelmoschus esculentus',
    family: 'Malvaceae',
    otherNames: ['Lady\'s Finger', 'Bhindi', 'Gumbo'],
    identificationConfidence: 0.92,
    funFact: 'Okra is a relative of the hibiscus and cotton plants, which explains its beautiful, showy flowers!',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Vibrant green stems with healthy trichomes (hairs) and developing flower buds showing no signs of pests or disease.',
    symptoms: [],
    overallImpression: 'Your plant looks incredibly vigorous and is happily preparing to bloom!',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Outdoor Full Sun',
    soilMoistureVisual: 'Moist',
    potTypeGuess: 'In Ground',
    indoorOrOutdoor: 'Outdoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Young',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: 'Annual (one growing season)',
    maxHeight: '4-7 feet',
  ),
  careGuide: CareGuide(
    summary: 'A heat-loving vegetable plant that requires plenty of sun and consistent moisture to produce its edible pods.',
    watering: WateringGuide(
      frequency: 'Every 2-3 Days',
      method: 'Deep soak at the base of the plant to keep the leaves dry and prevent fungal issues.',
      seasonalNote: 'Increase watering frequency during extreme summer heatwaves to prevent wilting.',
    ),
    light: LightGuide(
      idealCondition: 'At least 6-8 hours of direct sunlight daily.',
      currentAssessment: 'The lighting in the photo looks perfect—bright and direct.',
      adjustmentTip: 'Ensure no taller plants or structures are shading it as it grows.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Every 4 weeks',
      recommendedType: 'Balanced 10-10-10 vegetable fertilizer.',
      seasonalNote: 'Stop fertilizing once the plant reaches the end of its production cycle in late summer.',
    ),
    temperature: TemperatureGuide(
      idealRange: '75°F - 90°F',
      tolerance: 'Very heat tolerant; sensitive to frost.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'Moderate to High',
      boostMethods: ['Group plants together', 'Mulch around the base'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Aphids',
      cause: 'Small sap-sucking insects attracted to new growth.',
      prevention: 'Check under leaves regularly and encourage ladybugs.',
      fix: 'Blast them off with a strong stream of water or use insecticidal soap.',
    ),
    CommonIssue(
      problem: 'Powdery Mildew',
      cause: 'High humidity and poor airflow creating white fungal spots.',
      prevention: 'Space plants correctly and water only at the base.',
      fix: 'Prune affected leaves and improve air circulation.',
    ),
  ],
  proTip: 'Harvest the pods when they are 2-3 inches long; if they get too big, they become \'woody\' and tough to eat.',
  plantPersonality: 'A sun-worshipping powerhouse that\'s as tough as it is productive, rewarding your garden with tropical vibes.',
  safety: SafetyInfo(
    toxicityNote: 'No known toxicity concerns; the pods are widely consumed.',
    petSafe: true,
    hasSensitiveContent: false,
    notes: 'The tiny hairs on the stem can sometimes cause mild skin irritation for sensitive individuals.',
  ),
);
