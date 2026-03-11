import 'package:json_annotation/json_annotation.dart';

part 'itinerary_model.g.dart';

@JsonSerializable()
class ItineraryModel {
  final TripSummary summary;
  final List<ItineraryDay> dailyItinerary;
  final List<Recommendation> recommendations;
  final BudgetEstimate estimatedBudget;
  final List<TravelTip>? travelTips; // Make travelTips optional

  ItineraryModel({
    required this.summary,
    required this.dailyItinerary,
    required this.recommendations,
    required this.estimatedBudget,
    this.travelTips, // Make travelTips optional
  });

  factory ItineraryModel.fromJson(Map<String, dynamic> json) =>
      _$ItineraryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItineraryModelToJson(this);
}

@JsonSerializable()
class TripSummary {
  final String tripTitle;
  final String origin;
  final List<String> destinations;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfTravelers;
  final List<String> interests;

  TripSummary({
    required this.tripTitle,
    required this.origin,
    required this.destinations,
    required this.startDate,
    required this.endDate,
    required this.numberOfTravelers,
    required this.interests,
  });

  factory TripSummary.fromJson(Map<String, dynamic> json) =>
      _$TripSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$TripSummaryToJson(this);
}

@JsonSerializable()
class ItineraryDay {
  final int dayNumber;
  final DateTime date;
  final String title;
  final List<Activity> activities;

  ItineraryDay({
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.activities,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) =>
      _$ItineraryDayFromJson(json);

  Map<String, dynamic> toJson() => _$ItineraryDayToJson(this);
}

@JsonSerializable()
class Activity {
  final String time;
  final String title;
  final String description;
  final String category;
  final String location;
  final double? latitude;
  final double? longitude;
  final int durationMinutes;
  final double? cost;

  Activity({
    required this.time,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.latitude,
    this.longitude,
    required this.durationMinutes,
    this.cost,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}

@JsonSerializable()
class Recommendation {
  final String name;
  final String category;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final double? averageCost;
  final String imageUrl;

  Recommendation({
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.averageCost,
    required this.imageUrl,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationToJson(this);
}

@JsonSerializable()
class BudgetEstimate {
  final double totalEstimatedCost;
  final double perPersonCost;
  final Map<String, double> costBreakdown;

  BudgetEstimate({
    required this.totalEstimatedCost,
    required this.perPersonCost,
    required this.costBreakdown,
  });

  factory BudgetEstimate.fromJson(Map<String, dynamic> json) =>
      _$BudgetEstimateFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetEstimateToJson(this);
}

@JsonSerializable()
class TravelTip {
  final String title;
  final String description;

  TravelTip({
    required this.title,
    required this.description,
  });

  factory TravelTip.fromJson(Map<String, dynamic> json) =>
      _$TravelTipFromJson(json);

  Map<String, dynamic> toJson() => _$TravelTipToJson(this);
}