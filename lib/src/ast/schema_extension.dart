// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// Schema extensions are used to represent a schema which has been extended
/// from an original schema. 
///
/// https://graphql.github.io/graphql-spec/draft/#SchemaExtension
class SchemaExtension extends Definition {
  const SchemaExtension({
    this.definitions,
    this.directives,
  });

  final Iterable<RootOperationTypeDefinition> definitions;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.schemaExtension;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'definitions': definitions,
        'directives': directives,
      };
}
