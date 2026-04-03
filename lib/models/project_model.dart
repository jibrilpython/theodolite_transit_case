import 'package:theodolite_transit_case/enum/my_enums.dart';

class SurveyingInstrumentModel {
  String id;
  String geodeticIdentifier;
  InstrumentType instrumentType;
  String manufacturer;
  String countryOfManufacture;
  String eraOfProduction;
  String opticalSystem;
  String circleGraduation;
  String leastCount;
  String levelingSystem;
  String materialsAndFinish;
  String dimensionsAndWeight;
  ConditionState conditionState;
  String includedAccessories;
  String calibrationLogbook;
  String provenance;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  SurveyingInstrumentModel({
    required this.id,
    required this.geodeticIdentifier,
    required this.instrumentType,
    required this.manufacturer,
    required this.countryOfManufacture,
    required this.eraOfProduction,
    required this.opticalSystem,
    required this.circleGraduation,
    required this.leastCount,
    required this.levelingSystem,
    required this.materialsAndFinish,
    required this.dimensionsAndWeight,
    required this.conditionState,
    required this.includedAccessories,
    required this.calibrationLogbook,
    required this.provenance,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'geodeticIdentifier': geodeticIdentifier,
        'instrumentType': instrumentType.name,
        'manufacturer': manufacturer,
        'countryOfManufacture': countryOfManufacture,
        'eraOfProduction': eraOfProduction,
        'opticalSystem': opticalSystem,
        'circleGraduation': circleGraduation,
        'leastCount': leastCount,
        'levelingSystem': levelingSystem,
        'materialsAndFinish': materialsAndFinish,
        'dimensionsAndWeight': dimensionsAndWeight,
        'conditionState': conditionState.name,
        'includedAccessories': includedAccessories,
        'calibrationLogbook': calibrationLogbook,
        'provenance': provenance,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory SurveyingInstrumentModel.fromJson(Map<String, dynamic> json) =>
      SurveyingInstrumentModel(
        id: json['id'] ?? '',
        geodeticIdentifier: json['geodeticIdentifier'] ?? '',
        instrumentType: InstrumentType.values.asNameMap()[json['instrumentType']] ?? InstrumentType.other,
        manufacturer: json['manufacturer'] ?? '',
        countryOfManufacture: json['countryOfManufacture'] ?? '',
        eraOfProduction: json['eraOfProduction'] ?? '',
        opticalSystem: json['opticalSystem'] ?? '',
        circleGraduation: json['circleGraduation'] ?? '',
        leastCount: json['leastCount'] ?? '',
        levelingSystem: json['levelingSystem'] ?? '',
        materialsAndFinish: json['materialsAndFinish'] ?? '',
        dimensionsAndWeight: json['dimensionsAndWeight'] ?? '',
        conditionState: ConditionState.values.asNameMap()[json['conditionState']] ?? ConditionState.unknown,
        includedAccessories: json['includedAccessories'] ?? '',
        calibrationLogbook: json['calibrationLogbook'] ?? '',
        provenance: json['provenance'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
