import 'package:logging/logging.dart';

final log = Logger("MyApp");

void initLogger() {
  Logger.root.level = Level.INFO;
  assert(() {
    Logger.root.level = Level.FINE;
    return true;
  }());
  Logger.root.onRecord.listen((LogRecord record) {
    // ignore: avoid_print
    print("${record.time}: [${record.level.name}] ${record.message}");
  });
}
