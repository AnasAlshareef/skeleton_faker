import 'models.dart';

/// Only fromJson (json_serializable style).
class Profile {
  Profile._(this.name, this.email, this.status, this.joined);
  factory Profile.fromJson(Map<String, dynamic> json) => Profile._(
        json['name'] as String,
        json['email'] as String,
        Status.values.byName(json['status'] as String),
        DateTime.parse(json['joined'] as String),
      );
  final String name;
  final String email;
  final Status status;
  final DateTime joined;
}
