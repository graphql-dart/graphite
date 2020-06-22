import 'dart:convert' show Encoding, utf8;

import 'package:graphite/ast.dart' as ast;

Future<ast.Document> parseFile(Uri uri, {Encoding encoding = utf8}) {
  throw Exception('The `parseFile` is not support on this platform!');
}

ast.Document parseFileSync(Uri uri, {Encoding encoding = utf8}) {
  throw Exception('The `parseFileSync` is not support on this platform!');
}
