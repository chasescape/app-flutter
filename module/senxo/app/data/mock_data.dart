import 'package:senxo/gen_a/A.dart';
import 'models/equipment/equipment_model.dart';

/// MockData 用于 Home 页面的展示数据
/// History 页面使用独立的数据源（用户生成的数据）
class MockData {
  static final List<EquipmentModel> equipmentList = [
    EquipmentModel(
      id: '1',
      equipmentName: 'City Bike Frame',
      date: '2026-02-05',
      status: 'Great Condition',
      riskLevel: 'Low',
      image: A.assets_senxo_01_0,
      coinsUsed: 50,
      condition: 88,
      safety: 89,
      wearLevel: 'Low',
      aiAnalysis:
          'AI analysis shows this city bicycle frame is in great condition with minimal wear. No structural defects or safety hazards are identified.',
      type: 'Safe',
      issuesFound: [
        'Minor paint chipping',
        'Slight frame scuff marks',
      ],
      recommendations: [
        'Clean and wax regularly',
        'Inspect bolts before riding',
      ],
    ),
    EquipmentModel(
      id: '2',
      equipmentName: 'Hiking Backpack',
      date: '2026-02-01',
      status: 'Moderate Wear',
      riskLevel: 'Medium',
      image: A.assets_senxo_02_0,
      coinsUsed: 50,
      condition: 72,
      safety: 73,
      wearLevel: 'Moderate',
      aiAnalysis:
          'Moderate general wear is detected on this hiking backpack. The core structure remains intact, but close monitoring is suggested for outdoor use.',
      type: 'Warning',
      issuesFound: [
        'Strap fabric fading',
        'Minor zipper stiffness',
        'Light webbing abrasion',
      ],
      recommendations: [
        'Check strap tension before hikes',
        'Lubricate zippers monthly',
        'Avoid overloading heavy gear',
      ],
    ),
    EquipmentModel(
      id: '3',
      equipmentName: 'Mountain Bike',
      date: '2026-01-28',
      status: 'Good Condition',
      riskLevel: 'Low',
      image: A.assets_senxo_03_0,
      coinsUsed: 50,
      condition: 85,
      safety: 86,
      wearLevel: 'Low',
      aiAnalysis:
          'This mountain bike is in good overall condition with standard light wear. All functional parts perform well with no immediate safety risks.',
      type: 'Safe',
      issuesFound: [
        'Minor tire tread wear',
        'Light handlebar scratch',
      ],
      recommendations: [
        'Check tire pressure weekly',
        'Perform routine drivetrain cleaning',
      ],
    ),
    EquipmentModel(
      id: '4',
      equipmentName: 'MTB Full Gear',
      date: '2026-01-25',
      status: 'Excellent',
      riskLevel: 'Low',
      image: A.assets_senxo_04_0,
      coinsUsed: 50,
      condition: 94,
      safety: 95,
      wearLevel: 'Low',
      aiAnalysis:
          'Professional mountain biking gear set shows excellent condition. All protective and functional components are fully intact and safe for advanced trails.',
      type: 'Safe',
      issuesFound: [
        'Slight helmet shell scuff',
        'Minimal glove fabric fade',
      ],
      recommendations: [
        'Inspect helmet retention system',
        'Air out gear after each ride',
      ],
    ),
    EquipmentModel(
      id: '5',
      equipmentName: 'Climbing Gear Set',
      date: '2026-01-22',
      status: 'Moderate Wear',
      riskLevel: 'Medium',
      image: A.assets_senxo_05_0,
      coinsUsed: 50,
      condition: 65,
      safety: 63,
      wearLevel: 'Moderate',
      aiAnalysis:
          'Visible moderate wear across the complete climbing gear set. Core safety parts are functional but require professional review for high-altitude use.',
      type: 'Warning',
      issuesFound: [
        'Rope surface fraying spots',
        'Harness webbing discoloration',
        'Carabiner minor scratch marks',
      ],
      recommendations: [
        'Professional gear inspection required',
        'Retire worn rope if fraying worsens',
        'Test carabiner locking function regularly',
      ],
    ),
    EquipmentModel(
      id: '6',
      equipmentName: 'Mountaineering Suit',
      date: '2026-01-20',
      status: 'Excellent',
      riskLevel: 'Low',
      image: A.assets_senxo_06_0,
      coinsUsed: 50,
      condition: 91,
      safety: 90,
      wearLevel: 'Low',
      aiAnalysis:
          'AI analysis confirms this mountaineering suit is in excellent condition with effective insulation and waterproofing. No critical wear or safety risks detected for high-altitude use.',
      type: 'Safe',
      issuesFound: [
        'Minor surface fabric scuffs',
        'Slight edge stitching fading',
      ],
      recommendations: [
        'Re-waterproof coating annually',
        'Inspect seams before expeditions',
      ],
    ),
    EquipmentModel(
      id: '7',
      equipmentName: 'Downhill MTB Bike',
      date: '2026-01-18',
      status: 'Moderate Wear',
      riskLevel: 'Medium',
      image: A.assets_senxo_07_0,
      coinsUsed: 50,
      condition: 62,
      safety: 60,
      wearLevel: 'Moderate',
      aiAnalysis:
          'Moderate heavy use wear is detected on this downhill mountain bike. Core components remain functional, but professional inspection is advised for extreme trail riding.',
      type: 'Warning',
      issuesFound: [
        'Suspension component wear',
        'Tire tread moderate thinning',
        'Frame minor scratch marks',
      ],
      recommendations: [
        'Full suspension service needed',
        'Check brake pads regularly',
        'Avoid extreme jumps if worn',
      ],
    ),
    EquipmentModel(
      id: '8',
      equipmentName: 'Alpine Hiking Jacket',
      date: '2026-01-15',
      status: 'Great Condition',
      riskLevel: 'Low',
      image: A.assets_senxo_08_0,
      coinsUsed: 50,
      condition: 87,
      safety: 86,
      wearLevel: 'Low',
      aiAnalysis:
          'This alpine hiking jacket maintains great structural and protective condition. All weather-resistant layers are intact with no immediate safety concerns.',
      type: 'Safe',
      issuesFound: [
        'Light zipper track discoloration',
        'Minor outer layer scuffs',
      ],
      recommendations: [
        'Clean with technical gear detergent',
        'Inspect waterproof membrane yearly',
      ],
    ),
    EquipmentModel(
      id: '9',
      equipmentName: 'Trekking Pole Set',
      date: '2026-01-12',
      status: 'Moderate Wear',
      riskLevel: 'Medium',
      image: A.assets_senxo_09_0,
      coinsUsed: 50,
      condition: 70,
      safety: 68,
      wearLevel: 'Moderate',
      aiAnalysis:
          'Moderate regular use wear is found on trekking poles. The locking and shaft structure works properly, but close monitoring is recommended for rough terrain.',
      type: 'Warning',
      issuesFound: [
        'Tip rubber pad wear',
        'Shaft surface minor scratches',
        'Locking mechanism slight stiffness',
      ],
      recommendations: [
        'Replace worn tip pads promptly',
        'Test lock function before hikes',
        'Avoid over-twisting extensions',
      ],
    ),
    EquipmentModel(
      id: '10',
      equipmentName: 'Hiking Gear Kit',
      date: '2026-01-10',
      status: 'Critical Wear',
      riskLevel: 'High',
      image: A.assets_senxo_10_0,
      coinsUsed: 50,
      condition: 40,
      safety: 35,
      wearLevel: 'High',
      aiAnalysis:
          'CRITICAL: High wear detected across the hiking gear kit, including footwear and pack components. The gear is unsafe for long-distance or rough terrain use.',
      type: 'Critical',
      issuesFound: [
        'Boot sole severe wear',
        'Backpack strap fraying',
        'Mat surface tearing',
        'Gear fabric aging and brittleness',
      ],
      recommendations: [
        'Stop using for long hikes immediately',
        'Replace worn boots and mat',
        'Full gear replacement recommended',
        'Professional safety assessment required',
      ],
    ),
    EquipmentModel(
      id: '11',
      equipmentName: 'Hiking Backpack',
      date: '2026-01-08',
      status: 'Excellent',
      riskLevel: 'Low',
      image: A.assets_senxo_11_0,
      coinsUsed: 50,
      condition: 89,
      safety: 88,
      wearLevel: 'Low',
      aiAnalysis:
          'AI analysis shows this hiking backpack is in excellent condition with sturdy straps and intact storage compartments. No safety risks detected for casual and trail hiking.',
      type: 'Safe',
      issuesFound: [
        'Minor surface fabric scuffs',
        'Light buckle wear marks',
      ],
      recommendations: [
        'Clean interior regularly',
        'Check strap buckles before use',
      ],
    ),
    EquipmentModel(
      id: '12',
      equipmentName: 'Hiking Boot Set',
      date: '2026-01-06',
      status: 'Moderate Wear',
      riskLevel: 'Medium',
      image: A.assets_senxo_12_0,
      coinsUsed: 50,
      condition: 75,
      safety: 74,
      wearLevel: 'Moderate',
      aiAnalysis:
          'Moderate daily use wear is detected on this hiking boot and gear set. The supportive structure remains functional, but routine checks are recommended for rough trails.',
      type: 'Warning',
      issuesFound: [
        'Boot sole light thinning',
        'Trekking pole tip minor wear',
        'Slight leather surface fading',
      ],
      recommendations: [
        'Condition boot leather monthly',
        'Replace pole tips if worn down',
        'Test waterproofing regularly',
      ],
    ),
    EquipmentModel(
      id: '13',
      equipmentName: 'Camping Backpack',
      date: '2026-01-04',
      status: 'Great Condition',
      riskLevel: 'Low',
      image: A.assets_senxo_13_0,
      coinsUsed: 50,
      condition: 82,
      safety: 81,
      wearLevel: 'Low',
      aiAnalysis:
          'This large camping backpack is in great overall condition with stable weight distribution and undamaged mounting systems. No critical defects found.',
      type: 'Safe',
      issuesFound: [
        'Light bottom surface scuffing',
        'Minor strap webbing fading',
      ],
      recommendations: [
        'Reinforce stress seams annually',
        'Air dry after wet camping trips',
      ],
    ),
    EquipmentModel(
      id: '14',
      equipmentName: 'Climbing Helmet Set',
      date: '2026-01-02',
      status: 'Moderate Wear',
      riskLevel: 'Medium',
      image: A.assets_senxo_14_0,
      coinsUsed: 50,
      condition: 66,
      safety: 65,
      wearLevel: 'Moderate',
      aiAnalysis:
          'Visible moderate wear across the climbing helmet collection. Structural integrity is intact, but professional inspection is suggested for frequent technical climbing.',
      type: 'Warning',
      issuesFound: [
        'Helmet shell minor scuffs',
        'Strap elastic slight loosening',
        'Pad fabric light fading',
      ],
      recommendations: [
        'Inspect helmet inner foam regularly',
        'Replace worn straps immediately',
        'Avoid impact drops during storage',
      ],
    ),
    EquipmentModel(
      id: '15',
      equipmentName: 'Climbing Gear Pack',
      date: '2025-12-30',
      status: 'Critical Wear',
      riskLevel: 'High',
      image: A.assets_senxo_15_0,
      coinsUsed: 50,
      condition: 38,
      safety: 33,
      wearLevel: 'High',
      aiAnalysis:
          'CRITICAL: Severe wear detected on the integrated climbing gear pack and attached accessories. Structural and safety failures are likely under load.',
      type: 'Critical',
      issuesFound: [
        'Rope heavy fraying and wear',
        'Pack strap severe tearing',
        'Carabiner surface deep scratches',
        'Gear compartment fabric breakdown',
      ],
      recommendations: [
        'Cease all climbing use immediately',
        'Replace damaged rope and carabiners',
        'Full gear pack replacement required',
        'Professional safety inspection mandatory',
      ],
    ),
  ];

  static EquipmentModel? getEquipmentById(String id) {
    try {
      return equipmentList.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}
