import 'event_register_mixin.dart';
import 'event_tools.dart';

class EventRegister with ZapServerRegister {
  EventRegister([ServerEventBook? eventBook]) {
    if (eventBook != null) this.eventBook = eventBook;
  }
}
