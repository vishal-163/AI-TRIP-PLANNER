// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_input_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripInputModel _$TripInputModelFromJson(Map<String, dynamic> json) =>
    TripInputModel(
      origin: json['origin'] as String,
      destinations: (json['destinations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      budgetLevel: json['budgetLevel'] as String,
      numberOfTravelers: (json['numberOfTravelers'] as num).toInt(),
      interests:
          (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
      specialConstraints: json['specialConstraints'] as String,
    );

Map<String, dynamic> _$TripInputModelToJson(TripInputModel instance) =>
    <String, dynamic>{
      'origin': instance.origin,
      'destinations': instance.destinations,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'budgetLevel': instance.budgetLevel,
      'numberOfTravelers': instance.numberOfTravelers,
      'interests': instance.interests,
      'specialConstraints': instance.specialConstraints,
    };
