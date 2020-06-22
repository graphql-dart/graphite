library graphite.language.parser;

export 'src/language/parser/interface.dart'
    if (dart.library.io) 'src/language/parser/io.dart';
export 'src/language/parser/parser.dart' show Parser, parse;
