// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

library graphite.language.parser;

export 'src/parser/interface.dart' if (dart.library.io) 'src/parser/io.dart';
export 'src/parser/parser.dart' show Parser, parse;
