import 'package:meta/meta.dart' show required;

class QueryException implements Exception {
  QueryException({
    @required this.message,
    @required this.locations,
    @required this.path,
  });

  final String message;
  final List<Location> locations;

  Map<String, Object> toJson() => {
    'message': message,
    if (locations.isNotEmpty) ...{ 'locations': locations, }
  };
}

class Location {
  Location(this.line, this.column);

  final int line;
  final int column;
}
