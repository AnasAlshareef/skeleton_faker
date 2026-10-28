import 'package:skeleton_faker/skeleton_faker.dart';

part 'models.g.dart';

enum Status { active, closed }

class Country {
  Country(this.name, this.code);
  final String name;
  final String code;
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
    this.description,
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
  final String? description;
}
