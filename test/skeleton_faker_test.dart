import 'package:skeleton_faker/skeleton_faker.dart';
import 'package:test/test.dart';

class Airline {
  Airline(this.name, this.iata, this.rating);
  final String name;
  final String iata;
  final int rating;
}

Airline fakeAirline(Fake f) => Airline(f.name, f.code(), f.integer(1, 5));

void main() {
  test('builds the requested count of models', () {
    final list = fakeList(5, fakeAirline);
    expect(list, hasLength(5));
    expect(list.first.name, 'Lorem Lorem');
    expect(list.first.iata, 'XX');
  });

  test('same seed gives the same shape', () {
    final a = fakeList(10, fakeAirline).map((e) => e.rating).toList();
    final b = fakeList(10, fakeAirline).map((e) => e.rating).toList();
    expect(a, b);
  });

  test('integer stays in range', () {
    final f = Fake(1);
    for (var i = 0; i < 1000; i++) {
      expect(f.integer(1, 5), inInclusiveRange(1, 5));
    }
  });
}
