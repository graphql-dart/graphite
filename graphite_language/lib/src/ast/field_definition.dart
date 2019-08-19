// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#FieldDefinition
class FieldDefinition extends Node {
  const FieldDefinition(
      {@required this.name,
      @required this.type,
      this.description,
      this.directives,
      this.arguments});

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Iterable<InputValueDefinition> arguments;
  final Node type;

  @override
  NodeKind get kind => NodeKind.fieldDefinition;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'type': type,
        'description': description,
        'directives': directives,
        'arguments': arguments,
      };
}
