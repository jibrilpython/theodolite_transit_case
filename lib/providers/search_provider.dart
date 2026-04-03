import 'package:theodolite_transit_case/models/project_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<SurveyingInstrumentModel> filteredList(List<SurveyingInstrumentModel> list) {
    if (searchQuery.isEmpty) {
      return list;
    } else {
      final query = searchQuery.toLowerCase();
      return list
          .where((item) =>
              item.geodeticIdentifier.toLowerCase().contains(query) ||
              item.manufacturer.toLowerCase().contains(query) ||
              item.countryOfManufacture.toLowerCase().contains(query) ||
              item.opticalSystem.toLowerCase().contains(query) ||
              item.materialsAndFinish.toLowerCase().contains(query) ||
              item.provenance.toLowerCase().contains(query) ||
              item.eraOfProduction.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
