<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->
# Zaptools
A toolkit for Event-Driven websocket management

## Getting started

Zaptools provides tools for building event-driven websocket integration. It is built on websocket.

## Usage

### Server

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
    // When a event the event "myEvent" is received
    print("fire!");
   });

  final server = await app.start();
  print("listen on -> ${server.port}");
```

### Client (based on callbacks)

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

### Client (based on streams)

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


<!-- ## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more. -->
