// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#EnumTypeDefinition
class EnumTypeDefinition extends Definition {
  const EnumTypeDefinition(
      {@required this.name, this.description, this.directives, this.values});

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Iterable<EnumValueDefinition> values;

  @override
  NodeKind get kind => NodeKind.enumTypeDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitEnumTypeDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'description': description,
        'name': name,
        'directives': directives,
        'values': values,
      };
}
