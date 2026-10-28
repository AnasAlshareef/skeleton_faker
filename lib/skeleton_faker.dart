/// Placeholder model instances for skeleton loaders (e.g. Skeletonizer).
library;

import 'dart:math';

/// Hands out placeholder values. Seeded, so skeletons keep the same shape
/// across rebuilds instead of flickering.
class Fake {
  Fake([int seed = 0]) : _r = Random(seed);

  final Random _r;

  static final _factories = <Type, Object Function(Fake f)>{};

  /// Teaches the generator a type it cannot build itself (functions,
  /// third-party classes, interfaces with no concrete subclass...).
  static void register<T extends Object>(T Function(Fake f) build) =>
      _factories[T] = build;

  /// A registered [T]; generated code calls this for unknown types.
  T get<T>() {
    final build = _factories[T];
    if (build == null) {
      throw StateError(
        'skeleton_faker: no fake for $T. Call Fake.register<$T>((f) => ...) '
        'before building skeletons, or make the field nullable.',
      );
    }
    return build(this) as T;
  }

  static const _word = 'Lorem';

  /// Text of [words] words; the length is what shapes the skeleton bone.
  String text([int words = 2]) => List.filled(words, _word).join(' ');

  /// Text with a random word count in [min]..[max].
  String textBetween(int min, int max) => text(integer(min, max));

  String get name => text(2);
  String get title => text(3);
  String get paragraph => text(12);
  String get email => 'loading@example.com';
  String get phone => '+000 000 0000';
  String code([int length = 2]) => 'X' * length;

  /// Image URL; skeleton loaders cover it, so it never actually loads.
  String image([int size = 200]) => 'https://placehold.co/${size}x$size.png';

  int integer([int min = 0, int max = 100]) => min + _r.nextInt(max - min + 1);
  double decimal([double min = 0, double max = 100]) =>
      min + _r.nextDouble() * (max - min);
  bool get boolean => _r.nextBool();
  DateTime get date => DateTime(2000);
  Duration get duration => const Duration(minutes: 30);
  Uri get uri => Uri.parse(image());

  T pick<T>(List<T> values) => values[_r.nextInt(values.length)];

  List<T> list<T>(int count, T Function(Fake f) build) =>
      List.generate(count, (_) => build(this));
}

/// [count] placeholder models built by [build].
///
/// ```dart
/// final loading = fakeList(6, (f) => Airline(name: f.name, iata: f.code(), logo: f.image()));
/// Skeletonizer(enabled: isLoading, child: AirlineList(isLoading ? loading : airlines));
/// ```
List<T> fakeList<T>(int count, T Function(Fake f) build, {int seed = 0}) =>
    Fake(seed).list(count, build);

/// One placeholder model built by [build].
T fakeOne<T>(T Function(Fake f) build, {int seed = 0}) => build(Fake(seed));

/// Generates `$fake<ClassName>(Fake f)` from the class's constructor.
///
/// Needs `skeleton_faker_generator` and `build_runner` in dev_dependencies.
///
/// ```dart
/// part 'airline.g.dart';
///
/// @skeletonFake
/// class Airline { ... }
///
/// final loading = fakeList(6, $fakeAirline);
/// ```
class SkeletonFake {
  const SkeletonFake();
}

const skeletonFake = SkeletonFake();
