part of graphite.language.ast;

class Document extends Node {
  const Document({@required this.definitions});

  final Iterable<Node /* Definition | Extension */ > definitions;

  @override
  NodeKind get kind => NodeKind.document;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitDocument(this);
}
