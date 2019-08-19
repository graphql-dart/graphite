// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#InputValueDefinition
class InputValueDefinition extends Definition {
  const InputValueDefinition(
      {@required this.name,
      @required this.type,
      this.description,
      this.directives,
      this.defaultValue});

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Node /* NamedType | ListType | NonNullType */ type;
  final Node defaultValue;

  @override
  NodeKind get kind => NodeKind.inputValueDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitInputValueDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'type': type,
        'description': description,
        'directives': directives,
        'defaultValue': defaultValue,
      };
}
