// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

class FragmentDefinition extends Definition {
  const FragmentDefinition({
    @required this.name,
    @required this.typeCondition,
    @required this.selectionSet,
    this.directives,
  });

  final String name;
  final TypeCondition typeCondition;
  final Iterable<Directive> directives;
  final SelectionSet selectionSet;

  @override
  NodeKind get kind => NodeKind.fragmentDefinition;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'typeCondition': typeCondition,
        'directives': directives,
        'selectionSet': selectionSet,
      };
}
