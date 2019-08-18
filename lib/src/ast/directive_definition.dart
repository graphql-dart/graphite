// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#DirectiveDefinition
class DirectiveDefinition extends Definition {
  const DirectiveDefinition(
      {@required this.name, this.description, this.arguments, this.locations});

  final String name;
  final String description;
  final Iterable<InputValueDefinition> arguments;
  final Iterable<DirectiveLocation> locations;

  @override
  NodeKind get kind => NodeKind.directiveDefinition;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'description': description,
        'name': name,
        'arguments': arguments,
        'locations': locations,
      };
}

/// https://graphql.github.io/graphql-spec/draft/#DirectiveLocation
class DirectiveLocation {
  const DirectiveLocation._(this.name);

  factory DirectiveLocation.fromString(String name) {
    if (!_locations.containsKey(name)) {
      throw Exception('Unknown directive location!');
    }

    return _locations[name];
  }

  final String name;

  @override
  String toString() => 'DirectiveLocation<name=$name>';

  String toJson() => toString();

  // https://graphql.github.io/graphql-spec/draft/#ExecutableDirectiveLocation
  static const DirectiveLocation query = DirectiveLocation._('QUERY');
  static const DirectiveLocation mutation = DirectiveLocation._('MUTATION');
  static const DirectiveLocation subscription = DirectiveLocation._('SUBSCRIPTION');
  static const DirectiveLocation field = DirectiveLocation._('FIELD');
  static const DirectiveLocation fragmentDefinition = DirectiveLocation._('FRAGMENT_DEFINITION');
  static const DirectiveLocation fragmentSpread = DirectiveLocation._('FRAGMENT_SPREAD');
  static const DirectiveLocation inlineFragment = DirectiveLocation._('INLINE_FRAGMENT');
  static const DirectiveLocation variableDefinition = DirectiveLocation._('VARIABLE_DEFINITION');

  // https://graphql.github.io/graphql-spec/draft/#TypeSystemDirectiveLocation
  static const DirectiveLocation schema = DirectiveLocation._('SCHEMA');
  static const DirectiveLocation scalar = DirectiveLocation._('SCALAR');
  static const DirectiveLocation object = DirectiveLocation._('OBJECT');
  static const DirectiveLocation fieldDefinition = DirectiveLocation._('FIELD_DEFINITION');
  static const DirectiveLocation argumentDefinition = DirectiveLocation._('ARGUMENT_DEFINITION');
  static const DirectiveLocation interface = DirectiveLocation._('INTERFACE');
  static const DirectiveLocation union = DirectiveLocation._('UNION');
  static const DirectiveLocation kEnum = DirectiveLocation._('ENUM');
  static const DirectiveLocation enumValue = DirectiveLocation._('ENUM_VALUE');
  static const DirectiveLocation inputObject = DirectiveLocation._('INPUT_OBJECT');
  static const DirectiveLocation inputFieldDefinition = DirectiveLocation._('INPUT_FIELD_DEFINITION');

  static const Map<String, DirectiveLocation> _locations = {
    'QUERY': DirectiveLocation.query,
    'MUTATION': DirectiveLocation.mutation,
    'SUBSCRIPTION': DirectiveLocation.subscription,
    'FIELD': DirectiveLocation.field,
    'FRAGMENT_DEFINITION': DirectiveLocation.fragmentDefinition,
    'FRAGMENT_SPREAD': DirectiveLocation.fragmentSpread,
    'INLINE_FRAGMENT': DirectiveLocation.inlineFragment,
    'VARIABLE_DEFINITION': DirectiveLocation.variableDefinition,
    'SCHEMA': DirectiveLocation.schema,
    'SCALAR': DirectiveLocation.scalar,
    'OBJECT': DirectiveLocation.object,
    'FIELD_DEFINITION': DirectiveLocation.fieldDefinition,
    'ARGUMENT_DEFINITION': DirectiveLocation.argumentDefinition,
    'INTERFACE': DirectiveLocation.interface,
    'UNION': DirectiveLocation.union,
    'ENUM': DirectiveLocation.kEnum,
    'ENUM_VALUE': DirectiveLocation.enumValue,
    'INPUT_OBJECT': DirectiveLocation.inputObject,
    'INPUT_FIELD_DEFINITION': DirectiveLocation.inputFieldDefinition,
  };
}
