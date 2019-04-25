// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

import 'package:meta/meta.dart' show required;

class Source {
  const Source({@required this.body, this.name});

  final String body;
  final String name;
}
