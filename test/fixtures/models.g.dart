// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// SkeletonFakeGenerator
// **************************************************************************

Airline $fakeAirline(Fake f) => Airline(
  id: f.code(8),
  ownerId: f.code(8),
  paid: f.name,
  name: f.name,
  logo: f.image(),
  iata: f.code(),
  rating: f.integer(),
  score: f.decimal(),
  active: f.boolean,
  founded: f.date,
  status: Status.values.first,
  country: Country(f.name, f.code()),
  tags: f.list(3, (f) => f.name),
  description: f.paragraph,
);
