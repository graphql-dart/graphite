import 'package:meta/meta.dart' show required;

/// A reference to the line and column in the input source.
class Position {
  const Position(
      {@required this.offset, @required this.line, @required this.column});

  /// Index offset in the input source.
  final int offset;
  final int line;
  final int column;

  @override
  bool operator ==(Object other) =>
      other is Position &&
      other.offset == offset &&
      other.line == line &&
      other.column == column;

  @override
  int get hashCode => offset ^ line ^ column;

  @override
  String toString() => 'Position(offset=$offset, line=$line, column=$column)';

  Map<String, Object> toJson() => {
        'offset': offset,
        'line': line,
        'column': column,
      };
}

/// A span is a range of characters in the input source starting at the
/// character at [start] and ending just before [end].
class Spanning {
  const Spanning(this.start, this.end);

  factory Spanning.zeroWidth(Position position) => Spanning(position, position);

  /// Start position of the token.
  final Position start;

  /// End position of the token.
  final Position end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Spanning && other.start == start && other.end == end;

  @override
  String toString() => 'Spanning(start=$start, end=$end)';

  Map<String, Object> toJson() => {
        'start': start.toJson(),
        'end': end.toJson(),
      };
}
