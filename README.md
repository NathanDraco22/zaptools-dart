<h1 align="center">Zaptools</h1>

<p align="center">
  <img src="assets/zaptools-logo-150.png" />
  <h3 align="center">
    A toolkit for Event-Driven websocket management
  <h3>
</p>
<p align="center">
  <a href="https://github.com/invertase/melos">
    <img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square" alt="Maintained with Melos" />
  </a>
</p>

## Packages

| Name      | View Source                                                                                           |
|-----------|:------------------------------------------------------------------------------------------------------|
| Client    | [`zaptools_client`](https://github.com/NathanDraco22/zaptools-dart/tree/main/packages/zaptools_client)|
| Server    | [`zaptools_client`](https://github.com/NathanDraco22/zaptools-dart/tree/main/packages/zaptools_server)|

## Getting started

Zaptools provides tools for building event-driven websocket integration. It is built on top websocket.

## Usage

**Server**

```dart
  final app = ZapServer();

  app.onConnected((context) {
    // when a new client joined
    print("client connected");
  });

  app.onDisconnected((context) {
    // when a client left
    print("client disconnected!");
  });

  app.onEvent("myEvent", (context) {
    // When the event "myEvent" is received
    print("fire!");
   });

  final server = await app.start();
  print("listen on -> ${server.port}");
```

**Client (based on callbacks)**

```dart
  Uri uri = Uri.parse("ws://127.0.0.1:8000/");
  final zapClient = ClientConnector.connect(uri);

  zapClient.onConnected((eventData) {
    print("Connected");
   });

  zapClient.onDisconnected((eventData) {
    print("disconnected");
  });

  zapClient.sendEvent("myEvent", "payload");

  zapClient.onEvent("Hello", (eventData){
    print("event received");
  });

```

**Client (based on streams)**

```dart
  Uri uri = Uri.parse("ws://127.0.0.1:8000/");
  final zapClient = ClientConnector.attach(uri);

  zapClient.connectionState.listen((event) {
    if (event case ConnectionState.online) {
      print("connected!");
    }
    if (event case ConnectionState.offline) {
      print("disconnected!");
    }
  });

  zapClient.subscribeToEvent("myEVent").listen((eventData){
    print("event received!");
  });

```
> `attach` method returns a `subscriber`, it is a client based on streams

### Integrating with other frameworks (Server Side)

Zaptools can integrate with other frameworks that exposes the `HttpRequest` object of the `Dart:io` library, like Alfred framework.

[**Alfred**](https://github.com/rknell/alfred)
```dart
  final app = Alfred();

  final reg = EventRegister();

  reg.onConnected((contexts) {
    // when a new client joined
    print("client connected");
  });

  reg.onDisconnected((context) {
    // when a client left
    print("client disconnected!");
  });

  reg.onEvent("myEvent", (context) {
    // When a event the event "myEvent" is received
    print("fire!");
   });

  app.get("/ws", (HttpRequest req, HttpResponse res) {
    plugAndStartWithIO(req, reg);
  });
```
[Alfred](https://github.com/rknell/alfred) is a great framework to make server side apps with dart.

`EventRegister` has responsability to create events.
`plugAndStartWithIO` connect the `HttpRequest` with the `EventRegister` instance and upgrade the connection to websocket.

It planning to add Shelf and Frog support in the future.

**EventContext**

The `EventContext` object has the information about the current event, the `EventData` and the `WebSocketConnection` it is invoking the event.

```dart
    context.eventData; // EventData
    context.connection; // WebSocketConnection

```

`EventData` has the properties like `payload`, `name` (event name), `headers`.
```dart
    context.eventData.name; // name of the event
    context.eventData.payload; // payload of this event invoking
    context.eventData.headers; // headers of this event invoking
```
`connection` property is a instance of `WebSocketConnection` it has an `id` and is able to `send` and `close` the connection with the client.
```dart
    context.connection.id; //connection identifier
    context.connection.send("eventName", "payload"); // send to client
    context.connection.close(); // close the connection
```
> Executing `send` or `close` method in `onDisconnected` event it will throw an `Unhandled Error`

### Client Usage

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

