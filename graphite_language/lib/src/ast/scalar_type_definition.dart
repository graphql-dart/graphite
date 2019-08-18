// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#ScalarTypeDefinition
class ScalarTypeDefinition extends Node {
  const ScalarTypeDefinition(
      {@required this.name, this.description, this.directives});

  final String name;
  final String description;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.scalarTypeDefinition;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'description': description,
        'directives': directives,
      };
}
