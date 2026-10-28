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
    prices: {f.name: f.decimal()},
    flightTime: f.duration,
    location: (f.decimal(), f.decimal()),
    onTap: () {},
    format: (p0, {prefix}) => f.name,
    load: () => Future.value(f.list(3, (f) => Country(f.name, f.code()))),
    clock: f.get<Clock>(),
    profile: Profile.fromJson(<String, dynamic>{
      'name': f.name,
      'email': f.email,
      'status': Status.values.first.name,
      'joined': f.date.toIso8601String()
    }),
    description: f.paragraph,
    maybeClock: null);

Point $fakePoint(Fake f) => Point.origin(f.integer(), f.integer());

Booking $fakeBooking(Fake f) => Booking(code: f.code(), seats: f.integer());

Payment $fakePayment(Fake f) => Cash(f.decimal());

Page<T> $fakePage<T>(Fake f) => Page(f.list(3, (f) => f.get<T>()), f.integer());

Category $fakeCategory(Fake f) => Category(
    f.name,
    f.list(
        3,
        (f) => Category(f.name, f.list(3, (f) => Category(f.name, [], null)),
            Category(f.name, [], null))),
    Category(f.name, f.list(3, (f) => Category(f.name, [], null)),
        Category(f.name, [], null)));
