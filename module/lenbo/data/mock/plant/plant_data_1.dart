import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData1 = PlantAnalysis(
  assetImg: A.assets_lenbo_1,
  plantId: PlantId(
    commonName: 'Fiddle Leaf Fig',
    scientificName: 'Ficus lyrata',
    family: 'Moraceae',
    otherNames: ['Banjo Fig', 'Fiddle-leaf'],
    identificationConfidence: 0.99,
    funFact: 'In their native African rainforests, these plants can grow up to 50 feet tall and actually produce small green figs!',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Large, vibrant green leaves with a glossy sheen and no visible browning or drooping.',
    symptoms: [],
    overallImpression: 'Your Fiddle Leaf Fig looks exceptionally happy and well-adjusted to its current spot!',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Slightly Dry',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Mature',
    difficultyLevel: 'Moderate',
    expectedLifespan: '25-50 years',
    maxHeight: '6-10 feet (indoors)',
  ),
  careGuide: CareGuide(
    summary: 'A stunning architectural plant that thrives on consistency and bright, filtered light.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Drench the soil until water runs out the bottom, then let the top 2 inches dry out completely.',
      seasonalNote: 'Reduce watering in winter when growth slows down.',
    ),
    light: LightGuide(
      idealCondition: 'Bright, consistent indirect light from a North or East window.',
      currentAssessment: 'The current placement near the window appears ideal.',
      adjustmentTip: 'Rotate the pot 90 degrees every month to prevent the plant from leaning toward the light.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Once a month',
      recommendedType: 'Diluted liquid fertilizer high in nitrogen.',
      seasonalNote: 'Only fertilize during the active growing season (Spring and Summer).',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 75°F',
      tolerance: 'Sensitive to cold drafts and sudden temperature swings.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'High (above 50%)',
      boostMethods: ['Group with other plants', 'Use a room humidifier', 'Mist leaves occasionally'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Brown Leaf Edges',
      cause: 'Low humidity or inconsistent watering.',
      prevention: 'Maintain a regular watering schedule and boost humidity.',
      fix: 'Trim dead edges with clean shears and adjust your humidity levels.',
    ),
    CommonIssue(
      problem: 'Dropping Leaves',
      cause: 'Sudden environmental change or drafts.',
      prevention: 'Keep away from AC vents or heaters.',
      fix: 'Pick a permanent spot and avoid moving the plant frequently.',
    ),
    CommonIssue(
      problem: 'Root Rot',
      cause: 'Overwatering or poor drainage.',
      prevention: 'Ensure the pot has drainage holes and soil is well-aerated.',
      fix: 'Repot into fresh, dry soil and trim away any mushy, black roots.',
    ),
  ],
  proTip: 'Gently wipe the leaves with a soft, damp cloth once a month to remove dust; this helps the plant \'breathe\' and stay shiny.',
  plantPersonality: 'A bit of a \'drama queen\' who loves a steady routine but rewards your patience with spectacular, violin-shaped leaves.',
  safety: SafetyInfo(
    toxicityNote: 'Contains calcium oxalate crystals which are toxic to cats and dogs if chewed.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep out of reach of curious pets and small children.',
  ),
);
