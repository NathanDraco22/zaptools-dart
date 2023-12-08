
import 'event_tools.dart';

mixin ZapServerRegister {
  ServerEventBook eventBook = ServerEventBook();

  void onConnected(ContextCallBack callBack) {
    eventBook.saveEvent(ServerEvent("connected", callBack));
  }

  void onDisconnected(ContextCallBack callBack) {
    eventBook.saveEvent(ServerEvent("disconnected", callBack));
  }

  void onEvent(String eventName, ContextCallBack callback) {
    eventBook.saveEvent(ServerEvent(eventName, callback));
  }
}