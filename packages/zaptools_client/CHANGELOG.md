## 0.5.0
- Updated Dependencies
- BREAKING: now client can receive a json object without `headers` and empty `payload`
```json
{
    "eventName": "empty-event",
    "payload": null
}
```
Previous version without headers key will throw an exception


## 0.4.1
- Added `isConnected` property
- Added `currentConnectionState` property
- Update docs

## 0.4.0
- Removed unnecesary zapsubscriber
- added `onAnyEvent`

## 0.3.0
- Updated Dependencies
- BREAKING: connect method receive a URI object instead String.
- BREAKING: require `Dart ^3.5`

## 0.2.5
- Updated Readme

## 0.2.1

- Fixed Logs
- ZapClientState renamed
- tryReConnect added

## 0.1.3

- Fixed Logs
- Exposed EventData object


## 0.1.2

- Update screenshots

## 0.1.1

- Review with server.
- Added screenshots.


## 0.1.0

- Initial version.
