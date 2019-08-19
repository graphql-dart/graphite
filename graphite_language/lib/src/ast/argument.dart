// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#Argument
class Argument extends Node {
  const Argument({@required this.name, @required this.value});

  final Node value;
  final String name;

  @override
  NodeKind get kind => NodeKind.argument;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitArgument(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'value': value.toJson(),
      };
}
