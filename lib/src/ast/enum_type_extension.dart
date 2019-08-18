// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#EnumTypeExtension
class EnumTypeExtension extends Extension {
  const EnumTypeExtension(
      {@required this.name, this.directives, this.values});

  final String name;
  final Iterable<Directive> directives;
  final Iterable<EnumValueDefinition> values;

  @override
  NodeKind get kind => NodeKind.enumTypeExtension;

  @override
  Map<String, Object> toJson() => {
    'kind': kind.toString(),
    'name': name,
    'directives': directives,
    'values': values,
  };
}
