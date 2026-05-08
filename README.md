<h1 align="center">Zaptools</h1>

<p align="center">
  <img src="assets/zaptools-logo-150.png" />
  <h3 align="center">
    A toolkit for Event-Driven websocket management
  <h3>
</p>
<p align="center">
  <a href="https://pub.dev/packages/zaptools_client">
    <img src="https://img.shields.io/badge/client-0.4.0-blue?logo=flutter" alt="Client Version" />
  </a>
    <a href="https://pub.dev/packages/zaptools_server">
    <img src="https://img.shields.io/badge/server-0.3.0-blue?logo=dart" alt="Server Version" />
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

In order to get a connection with the server, `zaptools-dart` provides the `ZapConsumer` client.

`ZapConsumer` triggers a callback when an event is invoked.

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

**Sending Event**

`ZapConsumer` can send events to the server by using the `sendEvent` method:

```dart
zConsumer.sendEvent("eventName", "payload");
```

**Connect and Disconnect**

The `connect` method is used for both initial connections and reconnections to the server in case connection is lost.
```dart
zConsumer.connect();
```

The `disconnect` method closes the websocket connection with the server.
```dart
zConsumer.disconnect();
```

### Contributions are wellcome!

#### What's Next?
- [x] event management.
- [ ] comunication between clients.

