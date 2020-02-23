// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

import 'package:graphite_language/ast.dart' as ast;

class JsonPrinter extends ast.Visitor<Map<String, Object>> {
  @override
  Map<String, Object> visitDocument(ast.Document node) => {
        'kind': node.kind.toString(),
        'definitions':
            node.definitions.map((node) => node.accept(this)).toList(),
      };

  @override
  Map<String, Object> visitAlias(ast.Alias node) => {
        'kind': node.kind.toString(),
        'name': node.name,
      };

  @override
  Map<String, Object> visitArgument(ast.Argument node) => {
        'kind': node.kind.toString(),
        'value': node.value.accept(this),
      };

  @override
  Map<String, Object> visitBooleanValue(ast.BooleanValue node) => {
        'kind': node.kind.toString(),
        'value': node.value,
      };

  @override
  Map<String, Object> visitDirective(ast.Directive node) => {
        'kind': node.kind.toString(),
        'name': node.name,
        'arguments': node.arguments.map((node) => node.accept(this)).toList(),
      };

  @override
  Map<String, Object> visitEnumValue(ast.EnumValue node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitField(ast.Field node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitFloatValue(ast.FloatValue node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitFragmentDefinition(ast.FragmentDefinition node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitFragmentSpread(ast.FragmentSpread node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitInlineFragment(ast.InlineFragment node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitIntValue(ast.IntValue node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitListType(ast.ListType node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitListValue(ast.ListValue node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitNamedType(ast.NamedType node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitNonNullType(ast.NonNullType node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitNullValue(ast.NullValue node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitObjectValue(ast.ObjectValue node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitObjectField(ast.ObjectField node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitOperationDefinition(ast.OperationDefinition node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitOperationType(ast.OperationType node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitRootOperationTypeDefinition(
          ast.RootOperationTypeDefinition node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitSelectionSet(ast.SelectionSet node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitStringValue(ast.StringValue node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitSchemaDefinition(ast.SchemaDefinition node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitTypeCondition(ast.TypeCondition node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitVariable(ast.Variable node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitVariableDefinition(ast.VariableDefinition node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitScalarTypeDefinition(
          ast.ScalarTypeDefinition node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitObjectTypeDefinition(
          ast.ObjectTypeDefinition node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitInterfaceTypeDefinition(
          ast.InterfaceTypeDefinition node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitUnionTypeDefinition(ast.UnionTypeDefinition node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitEnumTypeDefinition(ast.EnumTypeDefinition node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitEnumValueDefinition(ast.EnumValueDefinition node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitInputObjectTypeDefinition(
          ast.InputObjectTypeDefinition node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitFieldDefinition(ast.FieldDefinition node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitInputValueDefinition(
          ast.InputValueDefinition node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitDirectiveDefinition(ast.DirectiveDefinition node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitScalarTypeExtension(ast.ScalarTypeExtension node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitSchemaExtension(ast.SchemaExtension node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitInterfaceTypeExtension(
          ast.InterfaceTypeExtension node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitUnionTypeExtension(ast.UnionTypeExtension node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitEnumTypeExtension(ast.EnumTypeExtension node) => {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitObjectTypeExtension(ast.ObjectTypeExtension node) =>
      {
        'kind': node.kind.toString(),
      };

  @override
  Map<String, Object> visitInputObjectTypeExtension(
          ast.InputObjectTypeExtension node) =>
      {
        'kind': node.kind.toString(),
      };
}
