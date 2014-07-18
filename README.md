## SaltBridge iOS

A small UIWebView replacement for using [Salt Edge Connect](https://docs.saltedge.com/guides/connect/) within your iOS app.

## How to use

* Add a new `SBWebView` instance to your view controller's view, also set a delegate for the web view
* Implement the `SBWebViewDelegate` methods in delegates' class
* Load the connect page in the web view

NOTE: Do not use the `delegate` property on `SKWebView`, since an `SKWebView` acts like a proxy object. If your class does need to respond to the `UIWebView` delegate methods, just implement them and the `SKWebView` instance will forward them to its `stageDelegate`.

## Example

TBD.

## References

1. [Salt Edge Connect Guide](https://docs.saltedge.com/guides/connect/)
