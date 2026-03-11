// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItineraryModel _$ItineraryModelFromJson(Map<String, dynamic> json) =>
    ItineraryModel(
      summary: TripSummary.fromJson(json['summary'] as Map<String, dynamic>),
      dailyItinerary: (json['dailyItinerary'] as List<dynamic>)
          .map((e) => ItineraryDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      estimatedBudget: BudgetEstimate.fromJson(
        json['estimatedBudget'] as Map<String, dynamic>,
      ),
      travelTips: (json['travelTips'] as List<dynamic>?)
          ?.map((e) => TravelTip.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItineraryModelToJson(
  ItineraryModel instance,
) => <String, dynamic>{
  'summary': instance.summary.toJson(),
  'dailyItinerary': instance.dailyItinerary.map((e) => e.toJson()).toList(),
  'recommendations': instance.recommendations.map((e) => e.toJson()).toList(),
  'estimatedBudget': instance.estimatedBudget.toJson(),
  'travelTips': ?instance.travelTips?.map((e) => e.toJson()).toList(),
};

TripSummary _$TripSummaryFromJson(Map<String, dynamic> json) => TripSummary(
  tripTitle: json['tripTitle'] as String,
  origin: json['origin'] as String,
  destinations: (json['destinations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  numberOfTravelers: (json['numberOfTravelers'] as num).toInt(),
  interests: (json['interests'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TripSummaryToJson(TripSummary instance) =>
    <String, dynamic>{
      'tripTitle': instance.tripTitle,
      'origin': instance.origin,
      'destinations': instance.destinations,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'numberOfTravelers': instance.numberOfTravelers,
      'interests': instance.interests,
    };

ItineraryDay _$ItineraryDayFromJson(Map<String, dynamic> json) => ItineraryDay(
  dayNumber: (json['dayNumber'] as num).toInt(),
  date: DateTime.parse(json['date'] as String),
  title: json['title'] as String,
  activities: (json['activities'] as List<dynamic>)
      .map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ItineraryDayToJson(ItineraryDay instance) =>
    <String, dynamic>{
      'dayNumber': instance.dayNumber,
      'date': instance.date.toIso8601String(),
      'title': instance.title,
      'activities': instance.activities.map((e) => e.toJson()).toList(),
    };

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  time: json['time'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  location: json['location'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  cost: (json['cost'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'time': instance.time,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'location': instance.location,
  'latitude': ?instance.latitude,
  'longitude': ?instance.longitude,
  'durationMinutes': instance.durationMinutes,
  'cost': ?instance.cost,
};

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    Recommendation(
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      averageCost: (json['averageCost'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'address': instance.address,
      'latitude': ?instance.latitude,
      'longitude': ?instance.longitude,
      'rating': ?instance.rating,
      'averageCost': ?instance.averageCost,
      'imageUrl': instance.imageUrl,
    };

BudgetEstimate _$BudgetEstimateFromJson(Map<String, dynamic> json) =>
    BudgetEstimate(
      totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
      perPersonCost: (json['perPersonCost'] as num).toDouble(),
      costBreakdown: (json['costBreakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$BudgetEstimateToJson(BudgetEstimate instance) =>
    <String, dynamic>{
      'totalEstimatedCost': instance.totalEstimatedCost,
      'perPersonCost': instance.perPersonCost,
      'costBreakdown': instance.costBreakdown,
    };

TravelTip _$TravelTipFromJson(Map<String, dynamic> json) => TravelTip(
  title: json['title'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$TravelTipToJson(TravelTip instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
};
