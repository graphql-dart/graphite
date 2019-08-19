// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

class StringValue extends Value<String> {
  const StringValue(String value) : super(value);

  @override
  NodeKind get kind => NodeKind.stringValue;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitStringValue(this);
}
