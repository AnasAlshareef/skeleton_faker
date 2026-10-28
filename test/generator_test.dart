import 'package:skeleton_faker/skeleton_faker.dart';
import 'package:test/test.dart';

import 'fixtures/models.dart';

void main() {
  test('generated faker fills every field from the model', () {
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
    expect(a.description, isNotNull);
  });

  test('works with fakeList', () {
    expect(fakeList(4, $fakeAirline), hasLength(4));
  });
}
