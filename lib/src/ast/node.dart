// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

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
  namedType,
  listType,
  nonNullType,
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
  scalarTypeExtension,
  interfaceTypeExtension,
  objectTypeExtension,
  inputObjectTypeExtension
}

@immutable
abstract class Node {
  const Node();

  /// Kind of this node.
  NodeKind get kind;

  void accept(VisitorBase visitor) => visitor.visit(this);

  Map<String, dynamic> toJson();
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
