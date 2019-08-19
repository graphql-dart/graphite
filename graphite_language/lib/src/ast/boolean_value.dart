// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#BooleanValue
class BooleanValue extends Value<bool> {
  // ignore:avoid_positional_boolean_parameters
  const BooleanValue(bool value) : super(value);

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitBooleanValue(this);

  @override
  NodeKind get kind => NodeKind.booleanValue;
}
