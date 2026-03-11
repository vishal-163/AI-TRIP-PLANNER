import 'package:json_annotation/json_annotation.dart';

// part 'trip_input_model.g.dart';

@JsonSerializable()
class TripInputModel {
  final String origin;
  final List<String> destinations;
  final DateTime startDate;
  final DateTime endDate;
  final String budgetLevel;
  final int numberOfTravelers;
  final List<String> interests;
  final String specialConstraints;

  TripInputModel({
    required this.origin,
    required this.destinations,
    required this.startDate,
    required this.endDate,
    required this.budgetLevel,
    required this.numberOfTravelers,
    required this.interests,
    required this.specialConstraints,
  });

  factory TripInputModel.fromJson(Map<String, dynamic> json) =>
      TripInputModel(
        origin: json['origin'] as String,
        destinations: List<String>.from(json['destinations'] as List),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        budgetLevel: json['budgetLevel'] as String,
        numberOfTravelers: json['numberOfTravelers'] as int,
        interests: List<String>.from(json['interests'] as List),
        specialConstraints: json['specialConstraints'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'origin': origin,
        'destinations': destinations,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'budgetLevel': budgetLevel,
        'numberOfTravelers': numberOfTravelers,
        'interests': interests,
        'specialConstraints': specialConstraints,
      };
}