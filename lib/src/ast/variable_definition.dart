// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#VariableDefinition
class VariableDefinition extends Definition {
  const VariableDefinition({
    @required this.variable,
    this.type,
    this.defaultValue,
    this.directives,
  });

  final Variable variable;
  final Node type;
  final Node defaultValue;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.variableDefinition;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'type': type,
        'defaultValue': defaultValue,
        'directives': directives,
      };
}
