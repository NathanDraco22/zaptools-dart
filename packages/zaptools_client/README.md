# Zaptools
A toolkit for Event-Driven websocket management

## Getting started

Zaptools provides tools for building event-driven websocket integration. It is built on top websocket.

## Usage

In order to get a connection with the server, `zaptools-dart` provides two clients: based on callbacks and based on streams.

`ZapClient` trigger a callback when a event is invoked

```dart
Uri uri = Uri.parse("ws://127.0.0.1:8000/");
  final zapClient = ClientConnector.connect(uri);

  zapClient.onConnected((eventData) {
    print("Connected"); //trigger when connected
   });

  zapClient.onDisconnected((eventData) {
    print("disconnected"); // trigger when disconnected
  });

  zapClient.onEvent("Hello", (eventData){
    print("event received"); // trigger when event "Hello" is received
  });

```

`ZapSubscriber` provides a `Stream` of `ConnectionState` enum and a `Stream` of event received. You can subscribe to specfic event or a group of event or to all event.

```dart
  Uri uri = Uri.parse("ws://127.0.0.1:8000/");
  final zapSubscriber = ClientConnector.attach(uri);

  zapSubscriber.connectionState.listen((event) {
    if (event case ConnectionState.online) {
      print("connected!"); 
    }
    if (event case ConnectionState.offline) {
      print("disconnected!"); 
    }
  });

  zapSubscriber.subscribeToEvent("myEVent").listen((eventData){
    print("event received!");
    // listen when 'myEvent' is received.
  });

  zapSubscriber.subscribeToEvents(["myEvent", "myOtherEvent"]).listen((event) { 
    print("a event is received");
    // listen when 'myEvent' or 'myOtherEvent' are received.
  });

  zapSubscriber.subscribeToAllEvent().listen((event) {
    print("whatever is received!");
    // listen all events 
  });
```
> remember `cancel` stream subscription if you don't need anymore

**Sending Event**

Both `ZapClient` and `ZapSubscriber` can send events to the servir by the method `send`

```dart
zapSubscriber.sendEvent("eventName", "payload");

zapClient.sendEvent("eventName", "payload");
```
**Disconnect, Reconnect**

`disconnect` method, close the websocket connection with the server.
```dart
zapClient.disconnect();
zapSubscriber.disconnect();
```
`tryReconnect` is a static method in `ClientConnector` class, similar to `connect` and `attach`, try to reconnect a `ZapConsumer` to the websocket connectio, `ZapConsumer` is the parent class of `ZapClient` and `ZapSubscriber`.
```dart
ClientConnector.tryReconnect(ZapConsumer); // try to reconnect a ZapClient or ZapSubscriber to the websocket connection.
```
**clean**

When you call `disconnect` method in a `ZapSubscriber` you close the webosocket connection but the `ZapSubscriber` still await events to emits. If for some reason `ZapSubscriber` is disconnected from a websocket, calling the `ClientConnector.tryReconnect` with the `ZapSubscriber` instance as parameter, if it reconnect is posible, `ZapSubscriber` will reconnect with the websocket and can emit the events received from the server, this prevents to create new subscription and prevent event duplicate in case of connection issue.

```dart
  Uri uri = Uri.parse("ws://127.0.0.1:8000/");
  final zapClient = ClientConnector.attach(uri);

  zapClient.connectionState.listen((event) {
    // code here
    // still received event after reconnect
  });

  zapClient.subscribeToEvent("myEVent").listen((eventData){
    // code here
    // still received event after reconnect
  });

  zapClient.disconnect();

  ClientConnector.tryReconnect(zapClient);
```

If you want to close completly the `ZapSubscriber` call method `clean`, this close and clean the connection with websocket into the `ZapSubscriber`.

```dart
  Uri uri = Uri.parse("ws://127.0.0.1:8000/");
  final zapClient = ClientConnector.attach(uri);

  zapClient.connectionState.listen((event) {
    // code here
    // No received event after clean
  });

  zapClient.subscribeToEvent("myEVent").listen((eventData){
    // code here
    // No received event after clean
  });

  zapClient.clean(); // all subscriptions "done"
```
> **Important: cancel all `StreamSuscription`**

### Contributions are wellcome!

#### What's Next?
- [x] event management.
- [ ] comunication between clients.