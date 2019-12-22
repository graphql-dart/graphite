part of graphite.language.ast;

/// `NodeKind` is used to uniquely identify what the node is.
enum NodeKind {
  document,
  operationDefinition,
  directive,
  variableDefinition,
  argument,
  alias,
  field,
  variable,
  fragmentSpread,
  inlineFragment,
  fragmentDefinition,
  selectionSet,

  // Types
  namedType,
  listType,
  nonNullType,

  // Values
  stringValue,
  booleanValue,
  enumValue,
  nullValue,
  listValue,
  intValue,
  objectValue,
  objectField,
  floatValue,

  typeCondition,
  operationType,

  // Definitions
  schemaDefinition,
  rootOperationTypeDefinition,
  scalarTypeDefinition,
  objectTypeDefinition,
  interfaceTypeDefinition,
  unionTypeDefinition,
  enumTypeDefinition,
  enumValueDefinition,
  inputObjectTypeDefinition,
  fieldDefinition,
  inputValueDefinition,
  directiveDefinition,

  // Extensions
  schemaExtension,
  scalarTypeExtension,
  interfaceTypeExtension,
  enumTypeExtension,
  unionTypeExtension,
  objectTypeExtension,
  inputObjectTypeExtension
}

@immutable
abstract class Node {
  const Node();

  /// Kind of this node.
  NodeKind get kind;

  T accept<T>(Visitor<T> visitor);

  Map<String, Object> toJson();
}

@immutable
abstract class Value<V> extends Node {
  const Value(this.value);

  final V value;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'value': value,
      };
}

@immutable
abstract class Definition extends Node {
  const Definition();
}

@immutable
abstract class Extension extends Node {
  const Extension();
}
