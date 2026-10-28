# skeleton_faker

Fake model instances for skeleton loaders (e.g. [skeletonizer](https://pub.dev/packages/skeletonizer)), generated from your model's fields. Seeded, so the skeleton never flickers between rebuilds.

## Install

```yaml
dependencies:
  skeleton_faker:
    git: https://github.com/AnasAlshareef/skeleton_faker.git

dev_dependencies:
  build_runner: any
  skeleton_faker_generator:
    git:
      url: https://github.com/AnasAlshareef/skeleton_faker.git
      path: generator
```

The runtime package has no dependencies. The generator is dev-only and supports analyzer 8 through 14, so it sits alongside freezed / json_serializable.

## Use

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
dart run build_runner build
```

```dart
Skeletonizer(
  enabled: isLoading,
  child: AirlineList(isLoading ? fakeList(6, $fakeAirline) : airlines),
);
```

## What it handles

| Model shape | How |
|---|---|
| Plain / named constructors | unnamed first, then named, then `fromJson` / `fromMap` |
| `fromJson`-only models | builds a JSON map from the fields |
| freezed (`factory X(...) = _X`) | calls the factory |
| sealed / abstract classes | fakes the first concrete subclass in the library |
| Generics `Page<T>` | `$fakePage<Airline>` |
| Self-referencing models | stops after 3 levels (empty lists, null parents) |

Field types: `String` (by name: `logo`/`image`/`url` → image URL, `email`, `phone`, `description` → paragraph, `title`, `code`/`iata`, `id`/`*Id`), `int`, `double`, `num`, `bool`, `DateTime`, `Duration`, `Uri`, `BigInt`, `Color`, enums, `List`/`Set`/`Map`/`Iterable`, records, functions, `Future`, `Stream`, nested models, `dynamic`/`Object`.

**Anything else** (third-party classes, interfaces with no implementation): nullable fields get `null`, optional params keep their default, and required ones are looked up at runtime. Register them once, e.g. in `main()`:

```dart
Fake.register<Clock>((f) => SystemClock());
```

A missing registration throws a message naming the exact `Fake.register<T>` call to add.

## By hand

```dart
final loading = fakeList(6, (f) => Airline(name: f.name, iata: f.code(), logo: f.image()));
```

`Fake` helpers: `text(n)`, `textBetween(min, max)`, `name`, `title`, `paragraph`, `email`, `phone`, `code(n)`, `image(size)`, `uri`, `integer`, `decimal`, `boolean`, `date`, `duration`, `pick(list)`, `list(n, build)`, `get<T>()`.
