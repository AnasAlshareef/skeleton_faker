import 'package:skeleton_faker/skeleton_faker.dart';

import 'profile.dart';

part 'models.g.dart';

enum Status { active, closed }

class Country {
  Country(this.name, this.code);
  final String name;
  final String code;
}

/// Third-party style type the generator cannot build.
abstract interface class Clock {
  DateTime now();
}

@skeletonFake
class Airline {
  Airline({
    required this.id,
    required this.ownerId,
    required this.paid,
    required this.name,
    required this.logo,
    required this.iata,
    required this.rating,
    required this.score,
    required this.active,
    required this.founded,
    required this.status,
    required this.country,
    required this.tags,
    required this.prices,
    required this.flightTime,
    required this.location,
    required this.onTap,
    required this.format,
    required this.load,
    required this.clock,
    required this.profile,
    this.description,
    this.maybeClock,
  });
  final String id;
  final String ownerId;
  final String paid;
  final String name;
  final String logo;
  final String iata;
  final int rating;
  final double score;
  final bool active;
  final DateTime founded;
  final Status status;
  final Country country;
  final List<String> tags;
  final Map<String, double> prices;
  final Duration flightTime;
  final (double, double) location;
  final void Function() onTap;
  final String Function(int value, {String? prefix}) format;
  final Future<List<Country>> Function() load;
  final Clock clock;
  final Profile profile;
  final String? description;
  final Clock? maybeClock;
}

/// Only named constructors.
@skeletonFake
class Point {
  Point.origin(this.x, this.y);
  final int x;
  final int y;
}

/// Freezed style: abstract class + redirecting factory.
@skeletonFake
abstract class Booking {
  const factory Booking({required String code, required int seats}) = _Booking;
  String get code;
  int get seats;
}

class _Booking implements Booking {
  const _Booking({required this.code, required this.seats});
  @override
  final String code;
  @override
  final int seats;
}

/// Sealed hierarchy: faked through its first subclass.
@skeletonFake
sealed class Payment {}

class Cash extends Payment {
  Cash(this.amount);
  final double amount;
}

/// Generic model.
@skeletonFake
class Page<T> {
  Page(this.items, this.total);
  final List<T> items;
  final int total;
}

/// Self-referencing: depth limit stops the cycle.
@skeletonFake
class Category {
  Category(this.name, this.children, this.parent);
  final String name;
  final List<Category> children;
  final Category? parent;
}
