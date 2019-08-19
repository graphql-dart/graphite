// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// A GraphQL Input Object defines a set of input fields; the input fields are
/// either scalars, enums, or other input objects.
///
/// https://graphql.github.io/graphql-spec/draft/#InputObjectTypeDefinition
class InputObjectTypeDefinition extends Definition {
  const InputObjectTypeDefinition({
    @required this.name,
    this.description,
    this.directives,
    this.fields,
  });

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Iterable<InputValueDefinition> fields;

  @override
  NodeKind get kind => NodeKind.inputObjectTypeDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitInputObjectTypeDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'description': description,
        'name': name,
        'directives': directives,
        'fields': fields,
      };
}
