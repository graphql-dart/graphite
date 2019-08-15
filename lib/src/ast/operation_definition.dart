// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// Type of the operation definition.
///
/// https://graphql.github.io/graphql-spec/draft/#OperationType
class OperationType extends Node {
  const OperationType._(this.name);

  factory OperationType.fromTokenKind(TokenKind kind) {
    switch (kind) {
      case TokenKind.queryKeyword:
        return query;

      case TokenKind.mutationKeyword:
        return mutation;

      case TokenKind.subscriptionKeyword:
        return subscription;
    }

    throw Exception('Unknown operation type!');
  }

  static const OperationType query = OperationType._('query');
  static const OperationType mutation = OperationType._('mutation');
  static const OperationType subscription = OperationType._('subscription');

  final String name;

  @override
  NodeKind get kind => NodeKind.operationType;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
      };
}

/// https://graphql.github.io/graphql-spec/draft/#OperationDefinition
class OperationDefinition extends Definition {
  const OperationDefinition({
    @required this.selectionSet,
    @required this.operationType,
    this.name,
    this.variableDefinitions,
    this.directives,
  });

  final OperationType operationType;
  final SelectionSet selectionSet;
  final String name;

  final Iterable<VariableDefinition> variableDefinitions;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.operationDefinition;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'operationType': operationType,
        'selectionSet': selectionSet,
        'variableDefinitions': variableDefinitions,
        'directives': directives,
      };
}
