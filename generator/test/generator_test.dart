import 'package:skeleton_faker/skeleton_faker.dart';
import 'package:test/test.dart';

import 'fixtures/models.dart';

class _FakeClock implements Clock {
  @override
  DateTime now() => DateTime(2000);
}

void main() {
  setUpAll(() => Fake.register<Clock>((f) => _FakeClock()));

  test('fills every field from the model', () async {
    final a = $fakeAirline(Fake());
    expect(a.name, 'Lorem Lorem');
    expect(a.logo, startsWith('https://'));
    expect(a.iata, 'XX');
    expect(a.id, hasLength(8));
    expect(a.ownerId, hasLength(8));
    expect(a.paid, 'Lorem Lorem');
    expect(a.status, Status.active);
    expect(a.country.code, 'XX');
    expect(a.tags, hasLength(3));
    expect(a.prices, hasLength(1));
    expect(a.flightTime, isA<Duration>());
    expect(a.location.$1, isA<double>());
    a.onTap();
    expect(a.format(1, prefix: 'x'), isA<String>());
    expect(await a.load(), hasLength(3));
    expect(a.clock.now(), DateTime(2000));
    expect(a.description, isNotNull);
  });

  test(
      'named constructor only', () => expect($fakePoint(Fake()).x, isA<int>()));

  test('fromJson only (private ctor in another file)', () {
    final p = $fakeAirline(Fake()).profile;
    expect(p.email, 'loading@example.com');
    expect(p.status, Status.active);
  });

  test('freezed-style redirecting factory', () {
    expect($fakeBooking(Fake()).code, 'XX');
  });

  test('sealed class uses a subclass', () {
    expect($fakePayment(Fake()), isA<Cash>());
  });

  test('generic model', () {
    Fake.register<Country>((f) => Country(f.name, f.code()));
    expect($fakePage<Country>(Fake()).items.first.code, 'XX');
  });

  test('self-referencing model stops at depth limit', () {
    final c = $fakeCategory(Fake());
    expect(c.children, hasLength(3));
    expect(c.children.first.children.first.children, isEmpty);
  });

  test('unregistered type explains the fix', () {
    expect(
      () => Fake().get<Uri>(),
      throwsA(predicate((e) => '$e'.contains('Fake.register<Uri>'))),
    );
  });

  test('works with fakeList', () {
    expect(fakeList(4, $fakeAirline), hasLength(4));
  });
}
