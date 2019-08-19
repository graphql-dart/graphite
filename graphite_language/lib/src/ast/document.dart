// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

class Document extends Node {
  const Document({@required this.definitions});

  final Iterable<Node /* Definition | Extension */ > definitions;

  @override
  NodeKind get kind => NodeKind.document;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitDocument(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'definitions': definitions,
      };
}
