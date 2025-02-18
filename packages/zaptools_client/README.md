# Zaptools
A toolkit for Event-Driven websocket management

## Getting started

Zaptools provides tools for building event-driven websocket integration. It is built on top websocket.

## Usage

In order to get a connection with the server, `zaptools-dart` provides two clients: based on callbacks and based on streams.

`ZapConsumer` trigger a callback when a event is invoked

```dart
  final zConsumer = ZapConsumer('ws://127.0.0.1:8000/')..connect();

  zConsumer.onConnected((eventData) {
    print('connected!');
  });

  zConsumer.onDisconnected((eventData) {
    print('disconnected!');
  });

  zConsumer.onEvent("myEvent", (eventData) { 
    print("myEvent Received");
  });

  zConsumer.onAnyEvent((eventData) {
    print("event received");
  });


```

**Sending Event**

Both `ZapConsumer` and `ZapSubscriber` can send events to the server by the method `send`

```dart
zConsumer.sendEvent("eventName", "payload");
```
**Connect, Disconnect, tryReconnect**

`connect` method is used for both intitial connections and reconnections to the server in case connection lost.
```dart
zConsumer.connect();
```

`disconnect` method, close the websocket connection with the server.
```dart
zConsumer.disconnect();
```

### Contributions are wellcome!

#### What's Next?
- [x] event management.
- [ ] comunication between clients.