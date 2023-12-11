<h1 align="center">Zaptools</h1>

<p align="center">
  <img src="assets/zaptools-logo-150.png" />
  <h3 align="center">
    A toolkit for Event-Driven websocket management
  <h3>
</p>
<p align="center">
  <a href="https://pub.dev/packages/zaptools_client">
    <img src="https://img.shields.io/badge/client-0.2.0-blue?logo=flutter" alt="Client Version" />
  </a>
    <a href="https://pub.dev/packages/zaptools_server">
    <img src="https://img.shields.io/badge/server-0.2.0-blue?logo=dart" alt="Server Version" />
  </a>
  <a href="https://github.com/invertase/melos">
    <img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square" alt="Maintained with Melos" />
  </a>
</p>

## Packages

| Name      | View Source                                                                                           |
|-----------|:------------------------------------------------------------------------------------------------------|
| Client    | [`zaptools_client`](https://github.com/NathanDraco22/zaptools-dart/tree/main/packages/zaptools_client)|
| Server    | [`zaptools_server`](https://github.com/NathanDraco22/zaptools-dart/tree/main/packages/zaptools_server)|

### Also Supported
| Lang               |Side  |View Source                                                                                           |
|:------------------:|:----:|:------------------------------------------------------------------------------------------------------|
|<a href="https://www.python.org" target="_blank"> <img src="https://upload.wikimedia.org/wikipedia/commons/archive/c/c3/20220730085403%21Python-logo-notext.svg" alt="python" width="25" height="25"/> </a>| Server |[`zaptools_python`](https://github.com/NathanDraco22/zaptools-python)|

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

**Client (based on streams)**

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
    context.connection; // WebSocketConnection
    context.eventName; // name of the event
    context.payload; // payload of this event invoking
    context.headers; // headers of this event invoking
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

Both `ZapConsumer` and `ZapSubscriber` can send events to the servir by the method `send`

```dart
zSubscriber.sendEvent("eventName", "payload");

zConsumer.sendEvent("eventName", "payload");
```
**Connect and Disconnect**

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

