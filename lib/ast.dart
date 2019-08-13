// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

library graphite.language.ast;

import 'package:graphite_language/token.dart';
import 'package:meta/meta.dart' show required, immutable;

part 'src/ast/document.dart';

part 'src/ast/operation_definition.dart';

part 'src/ast/directive.dart';

part 'src/ast/variable_definition.dart';

part 'src/ast/field.dart';

part 'src/ast/alias.dart';

part 'src/ast/argument.dart';

part 'src/ast/visitor.dart';

part 'src/ast/variable.dart';

part 'src/ast/node.dart';

part 'src/ast/fragment_spread.dart';

part 'src/ast/inline_fragment.dart';

part 'src/ast/fragment_definition.dart';

part 'src/ast/selection_set.dart';

part 'src/ast/list_type.dart';

part 'src/ast/named_type.dart';

part 'src/ast/non_null_type.dart';

part 'src/ast/object_value.dart';

part 'src/ast/float_value.dart';

part 'src/ast/int_value.dart';

part 'src/ast/string_value.dart';

part 'src/ast/boolean_value.dart';

part 'src/ast/list_value.dart';

part 'src/ast/enum_value.dart';

part 'src/ast/null_value.dart';

part 'src/ast/type_condition.dart';

part 'src/ast/schema_definition.dart';

part 'src/ast/union_type_definition.dart';

part 'src/ast/scalar_type_definition.dart';

part 'src/ast/object_type_definition.dart';

part 'src/ast/field_definition.dart';

part 'src/ast/input_value_definition.dart';

part 'src/ast/interface_type_definition.dart';

part 'src/ast/enum_type_definition.dart';

part 'src/ast/enum_value_definition.dart';

part 'src/ast/input_object_type_definition.dart';

part 'src/ast/scalar_type_extension.dart';

part 'src/ast/input_object_type_extension.dart';

part 'src/ast/object_type_extension.dart';
