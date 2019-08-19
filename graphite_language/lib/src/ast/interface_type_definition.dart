// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#InterfaceTypeDefinition
class InterfaceTypeDefinition extends Definition {
  const InterfaceTypeDefinition(
      {@required this.name, this.description, this.directives, this.fields});

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Iterable<FieldDefinition> fields;

  @override
  NodeKind get kind => NodeKind.interfaceTypeDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitInterfaceTypeDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'description': description,
        'directives': directives,
        'fields': fields,
      };
}
