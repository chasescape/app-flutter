import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData19 = PlantAnalysis(
  assetImg: A.assets_lenbo_19,
  plantId: PlantId(
    commonName: 'Monstera Deliciosa',
    scientificName: 'Monstera deliciosa',
    family: 'Araceae',
    otherNames: ['Swiss Cheese Plant', 'Split-leaf Philodendron', 'Mexican Breadfruit'],
    identificationConfidence: 0.98,
    funFact: 'In its native rainforest habitat, the holes in its leaves (fenestrations) help it withstand heavy tropical storms and allow light to reach the lower foliage.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Vibrant green foliage with well-defined fenestrations and strong upright stems. No visible pests or leaf spots.',
    symptoms: [],
    overallImpression: 'Your Monstera is looking absolutely stunning and clearly enjoys its current spot by the window!',
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
    expectedLifespan: '40+ years',
    maxHeight: '10-15 feet',
  ),
  careGuide: CareGuide(
    summary: 'A low-maintenance tropical beauty that rewards bright light with iconic, dramatic leaf holes.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Water thoroughly until it drains from the bottom; allow the top 2 inches of soil to dry before watering again.',
      seasonalNote: 'Reduce frequency in winter when growth slows; check soil moisture manually before adding water.',
    ),
    light: LightGuide(
      idealCondition: 'Bright, filtered sunlight near an east or south-facing window.',
      currentAssessment: 'The current lighting looks ideal, providing enough energy for those beautiful split leaves.',
      adjustmentTip: 'If new leaves lack holes, try moving it slightly closer to the light source.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Once a month during spring and summer.',
      recommendedType: 'Balanced liquid fertilizer diluted to half strength.',
      seasonalNote: 'Stop fertilizing during the dormant winter months.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 85°F (18°C - 29°C)',
      tolerance: 'Avoid temperatures below 50°F (10°C) and keep away from cold drafts.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'High (60%+)',
      boostMethods: ['Grouping with other plants', 'Using a humidifier', 'Misting the leaves regularly'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Yellowing Lower Leaves',
      cause: 'Usually overwatering or poor drainage.',
      prevention: 'Ensure the pot has drainage holes and don\'t let the plant sit in water.',
      fix: 'Let the soil dry out completely and check that the roots aren\'t mushy.',
    ),
    CommonIssue(
      problem: 'Brown Crispy Edges',
      cause: 'Low humidity or underwatering.',
      prevention: 'Keep humidity levels consistent and don\'t let the soil go bone-dry for too long.',
      fix: 'Increase misting and ensure you are watering deeply when the soil is dry.',
    ),
  ],
  proTip: 'Gently wipe the large leaves with a damp cloth once a month to remove dust; this helps the plant breathe and photosynthesize much more efficiently.',
  plantPersonality: 'This iconic socialite loves to show off its dramatic leaves and is surprisingly easy-going for such a superstar.',
  safety: SafetyInfo(
    toxicityNote: 'Contains calcium oxalate crystals which are irritating if ingested.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep out of reach of curious cats and dogs.',
  ),
);
