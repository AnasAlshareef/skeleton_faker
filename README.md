# skeleton_faker

Fake model instances for skeleton loaders (e.g. [skeletonizer](https://pub.dev/packages/skeletonizer)). Seeded, so the skeleton never flickers between rebuilds.

```yaml
dependencies:
  skeleton_faker:
    git: https://github.com/AnasAlshareef/skeleton_faker.git
```

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
