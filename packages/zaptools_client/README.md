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

```

`ZapSubscriber` provides a `Stream` of `ConnectionState` enum and a `Stream` of event received. You can subscribe to specfic event or a group of event or to all event.

```dart
  final zSubscriber = ZapSubscriber("ws://127.0.0.1:8000/")..connect();

  zSubscriber.connectionState.listen((event) {
    if (event case ConnectionState.online) {
      print("connected!"); 
    }
    if (event case ConnectionState.offline) {
      print("disconnected!"); 
    }
  });

  zSubscriber.subscribeToEvent("myEVent").listen((eventData){
    print("event received!");
    // listen when 'myEvent' is received.
  });

  zSubscriber.subscribeToEvents(["myEvent", "myOtherEvent"]).listen((event) { 
    print("a event is received");
    // listen when 'myEvent' or 'myOtherEvent' are received.
  });

  zSubscriber.subscribeToAllEvent().listen((event) {
    print("whatever is received!");
    // listen all events 
  });
```
> remember `cancel` stream subscription if you don't need anymore

**Sending Event**

Both `ZapConsumer` and `ZapSubscriber` can send events to the server by the method `send`

```dart
zSubscriber.sendEvent("eventName", "payload");

zConsumer.sendEvent("eventName", "payload");
```
**Connect, Disconnect, tryReconnect**

`connect` method is used for both intitial connections and reconnections to the server in case connection lost.
```dart
zConsumer.connect();
zSubscriber.connect();
```

`disconnect` method, close the websocket connection with the server.
```dart
zConsumer.disconnect();
zSubscriber.disconnect();
```


**clean**

When you call `disconnect` method in a `ZapSubscriber` you close the webosocket connection but the `ZapSubscriber` still await events to emits. If for some reason `ZapSubscriber` is disconnected from a websocket, calling the `connect` method `ZapSubscriber` will reconnect with the websocket and can emit the events received from the server, this prevents to create new subscription and prevent event duplicate in case of connection issue.

```dart
  final zSubscriber = ZapSubscriber("ws://127.0.0.1:8000/")..connect();

  zSubscriber.connectionState.listen((event) {
    // code here
    // still received event after reconnect
  });

  zSubscriber.subscribeToEvent("myEVent").listen((eventData){
    // code here
    // still received event after reconnect
  });

  zSubscriber.disconnect();

  zSubscriber.connect();
```

If you want to close completly the `ZapSubscriber` call method `clean`, this close and clean the connection with websocket into the `ZapSubscriber`.

```dart
  final zSubscriber = ZapSubscriber("ws://127.0.0.1:8000/")..connect();


  zSubscriber.connectionState.listen((event) {
    // code here
    // No received event after clean
  });

  zSubscriber.subscribeToEvent("myEVent").listen((eventData){
    // code here
    // No received event after clean
  });

  zSubscriber.clean(); // all subscriptions "done"
```
> **Important: cancel all `StreamSuscription`**

### Contributions are wellcome!

#### What's Next?
- [x] event management.
- [ ] comunication between clients.