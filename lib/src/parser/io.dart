import 'dart:convert' show Encoding, utf8;
import 'dart:io' show File, Platform;

import 'package:graphite_language/ast.dart' as ast;
import 'package:graphite_language/parser.dart' show parse;
import 'package:graphite_language/token.dart' show Source;

Future<ast.Document> parseFile(Uri uri, {Encoding encoding = utf8}) async {
  final file = File.fromUri(uri);
  final code = await file.readAsString(encoding: encoding);

  return parse(Source(
    body: code,
    name: uri.toFilePath(windows: Platform.isWindows),
  ));
}

ast.Document parseFileSync(Uri uri, {Encoding encoding = utf8}) {
  final file = File.fromUri(uri);
  final code = file.readAsStringSync(encoding: encoding);

  return parse(Source(
    body: code,
    name: uri.toFilePath(windows: Platform.isWindows),
  ));
}
