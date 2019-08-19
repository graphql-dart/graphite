// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#RootOperationTypeDefinition
class RootOperationTypeDefinition extends Definition {
  const RootOperationTypeDefinition(
      {@required this.operation, @required this.value});

  final OperationType operation;
  final NamedType value;

  @override
  NodeKind get kind => NodeKind.rootOperationTypeDefinition;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'operation': operation,
        'value': value,
      };
}

/// https://graphql.github.io/graphql-spec/draft/#SchemaDefinition
class SchemaDefinition extends Definition {
  const SchemaDefinition({
    @required this.definitions,
    this.directives,
  });

  final Iterable<RootOperationTypeDefinition> definitions;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.schemaDefinition;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'definitions': definitions,
        'directives': directives,
      };
}
