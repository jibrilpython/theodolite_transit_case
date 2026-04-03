import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theodolite_transit_case/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _geodeticIdentifier = '';
  InstrumentType _instrumentType = InstrumentType.theodolite;
  String _manufacturer = '';
  String _countryOfManufacture = '';
  String _eraOfProduction = '';
  String _opticalSystem = '';
  String _circleGraduation = '';
  String _leastCount = '';
  String _levelingSystem = '';
  String _materialsAndFinish = '';
  String _dimensionsAndWeight = '';
  ConditionState _conditionState = ConditionState.unknown;
  String _includedAccessories = '';
  String _calibrationLogbook = '';
  String _provenance = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  // Getters
  String get geodeticIdentifier => _geodeticIdentifier;
  InstrumentType get instrumentType => _instrumentType;
  String get manufacturer => _manufacturer;
  String get countryOfManufacture => _countryOfManufacture;
  String get eraOfProduction => _eraOfProduction;
  String get opticalSystem => _opticalSystem;
  String get circleGraduation => _circleGraduation;
  String get leastCount => _leastCount;
  String get levelingSystem => _levelingSystem;
  String get materialsAndFinish => _materialsAndFinish;
  String get dimensionsAndWeight => _dimensionsAndWeight;
  ConditionState get conditionState => _conditionState;
  String get includedAccessories => _includedAccessories;
  String get calibrationLogbook => _calibrationLogbook;
  String get provenance => _provenance;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  // Setters
  set geodeticIdentifier(String v) { _geodeticIdentifier = v; notifyListeners(); }
  set instrumentType(InstrumentType v) { _instrumentType = v; notifyListeners(); }
  set manufacturer(String v) { _manufacturer = v; notifyListeners(); }
  set countryOfManufacture(String v) { _countryOfManufacture = v; notifyListeners(); }
  set eraOfProduction(String v) { _eraOfProduction = v; notifyListeners(); }
  set opticalSystem(String v) { _opticalSystem = v; notifyListeners(); }
  set circleGraduation(String v) { _circleGraduation = v; notifyListeners(); }
  set leastCount(String v) { _leastCount = v; notifyListeners(); }
  set levelingSystem(String v) { _levelingSystem = v; notifyListeners(); }
  set materialsAndFinish(String v) { _materialsAndFinish = v; notifyListeners(); }
  set dimensionsAndWeight(String v) { _dimensionsAndWeight = v; notifyListeners(); }
  set conditionState(ConditionState v) { _conditionState = v; notifyListeners(); }
  set includedAccessories(String v) { _includedAccessories = v; notifyListeners(); }
  set calibrationLogbook(String v) { _calibrationLogbook = v; notifyListeners(); }
  set provenance(String v) { _provenance = v; notifyListeners(); }
  set notes(String v) { _notes = v; notifyListeners(); }
  set photoPath(String v) { _photoPath = v; notifyListeners(); }
  set tags(List<String> v) { _tags = v; notifyListeners(); }
  set dateAdded(DateTime v) { _dateAdded = v; notifyListeners(); }

  void clearAll() {
    _geodeticIdentifier = '';
    _instrumentType = InstrumentType.theodolite;
    _manufacturer = '';
    _countryOfManufacture = '';
    _eraOfProduction = '';
    _opticalSystem = '';
    _circleGraduation = '';
    _leastCount = '';
    _levelingSystem = '';
    _materialsAndFinish = '';
    _dimensionsAndWeight = '';
    _conditionState = ConditionState.unknown;
    _includedAccessories = '';
    _calibrationLogbook = '';
    _provenance = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
