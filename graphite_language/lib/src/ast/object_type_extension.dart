// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#ObjectTypeExtension
class ObjectTypeExtension extends Extension {
  const ObjectTypeExtension(
      {@required this.name, this.directives, this.interfaces, this.fields});

  final String name;
  final Iterable<Directive> directives;
  final Iterable<NamedType> interfaces;
  final Iterable<FieldDefinition> fields;

  @override
  NodeKind get kind => NodeKind.objectTypeExtension;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitObjectTypeExtension(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'interfaces': interfaces,
        'directives': directives,
        'fields': fields,
      };
}
