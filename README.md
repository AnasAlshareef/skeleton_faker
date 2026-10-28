# skeleton_faker

Fake model instances for skeleton loaders (e.g. [skeletonizer](https://pub.dev/packages/skeletonizer)). Seeded, so the skeleton never flickers between rebuilds.

```yaml
dependencies:
  skeleton_faker:
    git: https://github.com/AnasAlshareef/skeleton_faker.git
```

Also add `build_runner` to `dev_dependencies`.

## Auto from your model

```dart
import 'package:skeleton_faker/skeleton_faker.dart';

part 'airline.g.dart';

@skeletonFake
class Airline {
  Airline({required this.name, required this.logo, required this.iata, required this.country});
  final String name;
  final String logo;
  final String iata;
  final Country country;
}
```

```sh
dart run build_runner build -d
```

Generates `$fakeAirline(Fake f)`. Use it:

```dart
Skeletonizer(
  enabled: isLoading,
  child: AirlineList(isLoading ? fakeList(6, $fakeAirline) : airlines),
);
```

Reads the unnamed constructor. Fills String (by field name: `logo`/`image`/`url` → image URL, `email`, `phone`, `description` → paragraph, `title`, `code`/`iata`, `id`/`*Id`), int, double, bool, DateTime, enums (first value), List/Set (3 items), Map (empty), nested classes (3 levels deep).

## By hand

```dart
import 'package:skeleton_faker/skeleton_faker.dart';

final loading = fakeList(6, (f) => Airline(
  name: f.name,          // 'Lorem Lorem'
  iata: f.code(),        // 'XX'
  logo: f.image(),
  rating: f.integer(1, 5),
));

Skeletonizer(
  enabled: isLoading,
  child: AirlineList(isLoading ? loading : airlines),
);
```

`Fake` helpers: `text(n)`, `textBetween(min, max)`, `name`, `title`, `paragraph`, `email`, `phone`, `code(n)`, `image(size)`, `integer`, `decimal`, `boolean`, `date`, `pick(list)`, `list(n, build)`.
