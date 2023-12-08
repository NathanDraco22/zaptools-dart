import 'package:uuid/uuid.dart';

abstract class ZapIdStrategy {
  String eval([String? id]);

  const ZapIdStrategy();
}

class DefaultIDStrategy extends ZapIdStrategy {
  final idHeading = "zpt";

  const DefaultIDStrategy();

  @override
  String eval([String? id]) {
    if (id != null) return id;
    final uuid = Uuid();
    uuid.v4();
    return "$idHeading-${uuid.v4()}";
  }
}
