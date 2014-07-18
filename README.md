## SaltBridge iOS

A small `UIWebView` replacement for using [Salt Edge Connect](https://docs.saltedge.com/guides/connect/) within your iOS app.

## Requirements

iOS 6, ARC.

## Installation
### CocoaPods

TBD.

### Source

Clone this repository

`$ git clone git@github.com:saltedge/saltbridge-ios.git`

Copy the `SBWebView` folder into your project.

## Usage

* Import the class and delegate files into your view controller
* Add a new `SBWebView` instance to your view controller's view, also set a `stageDelegate` for the web view
* Implement the `SBWebViewDelegate` methods in delegates' class
* Load the connect page in the web view

**NOTE:** Do not use the `delegate` property on `SKWebView`, since an `SKWebView` acts like a proxy object. If your class does need to respond to the `UIWebView` delegate methods, just implement them and the `SKWebView` instance will forward them to its `stageDelegate`.

## Example

Import the class and delegate files into your view controller, also let your view controller conform to the `SBWebViewDelegate` protocol.

```objc
#import "SBWebView.h"
#import "SBWebViewDelegate.h"
// ... snip ...

@interface MyViewController() <SKWebViewDelegate>
// ... snip ...
```

Instantiate a `SBWebView` and add it to your controller:

```objc
SKWebView* connectWebView = [[SBWebView alloc] initWithFrame:self.view.frame stateDelegate:self];
```

Implement the `SBWebViewDelegate` methods in your controller:

```objc
// ... snip ...

- (void)webView:(SBWebView *)webView receivedCallbackWithResponse:(NSDictionary *)response
{
    NSNumber* loginID    = response[SBLoginIdKey];
    NSString* loginState = response[SBLoginStateKey];
    // do something with the data...
}

- (void)webView:(SBWebView *)webView receivedCallbackWithError:(NSError *)error
{
  // handle the error...
}
```

Keep in mind that you can also implement the `UIWebView` delegate methods:

```objc
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  // the method will be called after SKWebView has finished processing it
}
```

Load the Salt Edge Connect URL into the web view and you're good to go:

```objc
[connectWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:connectURLString]]];
```

## References

1. [Salt Edge Connect Guide](https://docs.saltedge.com/guides/connect/)
