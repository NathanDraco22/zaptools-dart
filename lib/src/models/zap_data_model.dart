import 'dart:convert';

class ZapSocketData {
  String zapId;
  String zapAdapter;
  String event;
  dynamic payload;

  ZapSocketData(
      {required this.zapId,
      required this.zapAdapter,
      required this.event,
      this.payload});

  factory ZapSocketData.fromJsonString(String jsonString) {
    final result = jsonDecode(jsonString);

    return ZapSocketData(
        zapId: result["zapId"],
        zapAdapter: result["zapAdapter"],
        event: result["event"],
        payload: result["payload"]);
  }

  String toJsonEncoded() {
    Map<String, dynamic> zapMap = {
      "zapId": zapId,
      "zapAdapter": zapAdapter,
      "event": event,
      "payload": payload
    };

    return jsonEncode(zapMap);
  }
}

class SocketData {
  SocketData(this._event, this._payload);

  final String _event;
  final dynamic _payload;

  String get event => _event;
  dynamic get payload => _payload;

  @override
  String toString() {
    return "event : $_event - payload : $_payload";
  }
}
