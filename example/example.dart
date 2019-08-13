import 'package:graphite_language/lexer.dart';
import 'package:graphite_language/token.dart';

void main() {
  final l = Lexer(
      const Source(
        body: 'query {\n'
            '    user(username: "\\u123") {\n'
            '        firstName,\n'
            '        lastName\n'
            '    }\n'
            '}\n',
      ),
      shouldHighlightSourceInExceptions: true);

  try {
    print(l.lex());
  } catch (err) {
    print(err.toString().trim());
  }
}
