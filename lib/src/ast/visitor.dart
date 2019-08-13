// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

abstract class VisitorBase {
  void visit(Node node) {
    switch (node.kind) {
      case NodeKind.document:
        return visitDocument(node as Document);

      case NodeKind.alias:
        return visitAlias(node as Alias);

      case NodeKind.argument:
        return visitArgument(node as Argument);

      case NodeKind.booleanValue:
        return visitBooleanValue(node as BooleanValue);

      case NodeKind.directive:
        return visitDirective(node as Directive);

      case NodeKind.enumValue:
        return visitEnumValue(node as EnumValue);

      case NodeKind.field:
        return visitField(node as Field);

      case NodeKind.floatValue:
        return visitFloatValue(node as FloatValue);

      case NodeKind.fragmentDefinition:
        return visitFragmentDefinition(node as FragmentDefinition);

      case NodeKind.fragmentSpread:
        return visitFragmentSpread(node as FragmentSpread);

      case NodeKind.inlineFragment:
        return visitInlineFragment(node as InlineFragment);

      case NodeKind.intValue:
        return visitIntValue(node as IntValue);

      case NodeKind.listType:
        return visitListType(node as ListType);

      case NodeKind.listValue:
        return visitListValue(node as ListValue);

      case NodeKind.namedType:
        return visitNamedType(node as NamedType);

      case NodeKind.nonNullType:
        return visitNonNullType(node as NonNullType);

      case NodeKind.nullValue:
        return visitNullValue(node as NullValue);

      case NodeKind.objectField:
        return visitObjectField(node as ObjectField);

      case NodeKind.objectValue:
        return visitObjectValue(node as ObjectValue);

      case NodeKind.operationDefinition:
        return visitOperationDefinition(node as OperationDefinition);

      case NodeKind.operationType:
        return visitOperationType(node as OperationType);

      case NodeKind.rootOperationTypeDefinition:
        return visitRootOperationTypeDefinition(
            node as RootOperationTypeDefinition);

      case NodeKind.schemaDefinition:
        return visitSchemaDefinition(node as SchemaDefinition);

      case NodeKind.selectionSet:
        return visitSelectionSet(node as SelectionSet);

      case NodeKind.stringValue:
        return visitStringValue(node as StringValue);

      case NodeKind.typeCondition:
        return visitTypeCondition(node as TypeCondition);

      case NodeKind.variable:
        return visitVariable(node as Variable);

      case NodeKind.variableDefinition:
        return visitVariableDefinition(node as VariableDefinition);

      case NodeKind.scalarTypeDefinition:
        return visitScalarTypeDefinition(node as ScalarTypeDefinition);

      case NodeKind.objectTypeDefinition:
        return visitObjectTypeDefinition(node as ObjectTypeDefinition);

      case NodeKind.interfaceTypeDefinition:
        return visitInterfaceTypeDefinition(node as InterfaceTypeDefinition);

      case NodeKind.unionTypeDefinition:
        return visitUnionTypeDefinition(node as UnionTypeDefinition);

      case NodeKind.enumTypeDefinition:
        return visitEnumTypeDefinition(node as EnumTypeDefinition);

      case NodeKind.enumValueDefinition:
        return visitEnumValueDefinition(node as EnumValueDefinition);

      case NodeKind.inputObjectTypeDefinition:
        return visitInputTypeDefinition(node as InputObjectTypeDefinition);

      case NodeKind.fieldDefinition:
        return visitFieldDefinition(node as FieldDefinition);

      case NodeKind.inputValueDefinition:
        return visitInputValueDefinition(node as InputValueDefinition);

      case NodeKind.scalarTypeExtension:
        return visitScalarTypeExtension(node as ScalarTypeExtension);

      case NodeKind.objectTypeExtension:
        return visitObjectTypeExtension(node as ObjectTypeExtension);

      case NodeKind.inputObjectTypeExtension:
        return visitInputObjectTypeExtension(node as InputObjectTypeExtension);
    }
  }

  void visitDocument(Document node);

  void visitAlias(Alias node);

  void visitArgument(Argument node);

  void visitBooleanValue(BooleanValue node);

  void visitDirective(Directive node);

  void visitEnumValue(EnumValue node);

  void visitField(Field node);

  void visitFloatValue(FloatValue node);

  void visitFragmentDefinition(FragmentDefinition node);

  void visitFragmentSpread(FragmentSpread node);

  void visitInlineFragment(InlineFragment node);

  void visitIntValue(IntValue node);

  void visitListType(ListType node);

  void visitListValue(ListValue node);

  void visitNamedType(NamedType node);

  void visitNonNullType(NonNullType node);

  void visitNullValue(NullValue node);

  void visitObjectValue(ObjectValue node);

  void visitObjectField(ObjectField node);

  void visitOperationDefinition(OperationDefinition node);

  void visitOperationType(OperationType node);

  void visitRootOperationTypeDefinition(RootOperationTypeDefinition node);

  void visitSelectionSet(SelectionSet node);

  void visitStringValue(StringValue node);

  void visitSchemaDefinition(SchemaDefinition node);

  void visitTypeCondition(TypeCondition node);

  void visitVariable(Variable node);

  void visitVariableDefinition(VariableDefinition node);

  void visitScalarTypeDefinition(ScalarTypeDefinition node);

  void visitObjectTypeDefinition(ObjectTypeDefinition node);

  void visitInterfaceTypeDefinition(InterfaceTypeDefinition node);

  void visitUnionTypeDefinition(UnionTypeDefinition node);

  void visitEnumTypeDefinition(EnumTypeDefinition node);

  void visitEnumValueDefinition(EnumValueDefinition node);

  void visitInputTypeDefinition(InputObjectTypeDefinition node);

  void visitFieldDefinition(FieldDefinition node);

  void visitInputValueDefinition(InputValueDefinition node);

  void visitScalarTypeExtension(ScalarTypeExtension node);

  void visitObjectTypeExtension(ObjectTypeExtension node);

  void visitInputObjectTypeExtension(InputObjectTypeExtension node);
}
