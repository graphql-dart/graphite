// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

abstract class Visitor<T> {
  /// Visits [Document] node.
  T visitDocument(Document node);

  /// Visits [Alias] node.
  T visitAlias(Alias node);

  /// Visits [Argument] node.
  T visitArgument(Argument node);

  /// Visits [BooleanValue] node.
  T visitBooleanValue(BooleanValue node);

  /// Visits [Directive] node.
  T visitDirective(Directive node);

  /// Visits [EnumValue] node.
  T visitEnumValue(EnumValue node);

  /// Visits [Field] node.
  T visitField(Field node);

  /// Visits [FloatValue] node.
  T visitFloatValue(FloatValue node);

  /// Visits [FragmentDefinition] node.
  T visitFragmentDefinition(FragmentDefinition node);

  /// Visits [FragmentSpread] node.
  T visitFragmentSpread(FragmentSpread node);

  /// Visits [InlineFragment] node.
  T visitInlineFragment(InlineFragment node);

  /// Visits [IntValue] node.
  T visitIntValue(IntValue node);

  /// Visits [ListType] node.
  T visitListType(ListType node);

  /// Visits [ListValue] node.
  T visitListValue(ListValue node);

  /// Visits [NamedType] node.
  T visitNamedType(NamedType node);

  /// Visits [NonNullType] node.
  T visitNonNullType(NonNullType node);

  /// Visits [NullValue] node.
  T visitNullValue(NullValue node);

  /// Visits [ObjectValue] node.
  T visitObjectValue(ObjectValue node);

  /// Visits [ObjectField] node.
  T visitObjectField(ObjectField node);

  /// Visits [OperationDefinition] node.
  T visitOperationDefinition(OperationDefinition node);

  /// Visits [OperationType] node.
  T visitOperationType(OperationType node);

  /// Visits [RootOperationTypeDefinition] node.
  T visitRootOperationTypeDefinition(RootOperationTypeDefinition node);

  /// Visits [SelectionSet] node.
  T visitSelectionSet(SelectionSet node);

  /// Visits [StringValue] node.
  T visitStringValue(StringValue node);

  /// Visits [SchemaDefinition] node.
  T visitSchemaDefinition(SchemaDefinition node);

  /// Visits [TypeCondition] node.
  T visitTypeCondition(TypeCondition node);

  /// Visits [Variable] node.
  T visitVariable(Variable node);

  /// Visits [VariableDefinition] node.
  T visitVariableDefinition(VariableDefinition node);

  /// Visits [ScalarTypeDefinition] node.
  T visitScalarTypeDefinition(ScalarTypeDefinition node);

  /// Visits [ObjectTypeDefinition] node.
  T visitObjectTypeDefinition(ObjectTypeDefinition node);

  /// Visits [InterfaceTypeDefinition] node.
  T visitInterfaceTypeDefinition(InterfaceTypeDefinition node);

  /// Visits [UnionTypeDefinition] node.
  T visitUnionTypeDefinition(UnionTypeDefinition node);

  /// Visits [EnumTypeDefinition] node.
  T visitEnumTypeDefinition(EnumTypeDefinition node);

  /// Visits [EnumValueDefinition] node.
  T visitEnumValueDefinition(EnumValueDefinition node);

  /// Visits [InputObjectTypeDefinition] node.
  T visitInputObjectTypeDefinition(InputObjectTypeDefinition node);

  /// Visits [FieldDefinition] node.
  T visitFieldDefinition(FieldDefinition node);

  /// Visits [InputValueDefinition] node.
  T visitInputValueDefinition(InputValueDefinition node);

  /// Visits [DirectiveDefinition] node.
  T visitDirectiveDefinition(DirectiveDefinition node);

  /// Visits [ScalarTypeExtension] node.
  T visitScalarTypeExtension(ScalarTypeExtension node);

  /// Visits [SchemaExtension] node.
  T visitSchemaExtension(SchemaExtension node);

  /// Visits [InterfaceTypeExtension] node.
  T visitInterfaceTypeExtension(InterfaceTypeExtension node);

  /// Visits [UnionTypeExtension] node.
  T visitUnionTypeExtension(UnionTypeExtension node);

  /// Visits [EnumTypeExtension] node.
  T visitEnumTypeExtension(EnumTypeExtension node);

  /// Visits [ObjectTypeExtension] node.
  T visitObjectTypeExtension(ObjectTypeExtension node);

  /// Visits [InputObjectTypeExtension] node.
  T visitInputObjectTypeExtension(InputObjectTypeExtension node);
}
