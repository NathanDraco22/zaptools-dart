# Zaptools
A toolkit for Event-Driven websocket management

## Getting started

Zaptools provides tools for building event-driven websocket integration. It is built on top websocket.

## Usage

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

### Integrating with other frameworks

Zaptools can integrate with other frameworks that exposes the `HttpRequest` object from the `dart:io` library, like Alfred framework.

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
    final connector = IOConnector(req, reg);
    connector.start();
  });
```
[Alfred](https://github.com/rknell/alfred) is a great framework to make server side apps with dart.

`EventRegister` has responsability to create events.
`IOConnecter` connect the `HttpRequest` with the `EventRegister` instance and upgrade the connection to websocket.

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

### Contributions are wellcome!

#### What's Next?
- [x] event management.
- [ ] comunication between clients.
