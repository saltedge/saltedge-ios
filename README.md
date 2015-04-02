## SaltEdge iOS

A handful of classes to help you interact with the Salt Edge API from your iOS app.

## Requirements

iOS 6+, ARC.

## Installation
### CocoaPods

Add the pod to your `Podfile`

```ruby
# ... snip ...

pod 'SaltEdge-iOS'
```

Install the pod

`$ pod install`

### Source

Clone this repository

`$ git clone git@github.com:saltedge/saltedge-ios.git`

Copy the `Classes` folder into your project.

## Connecting logins using the sample app

1. Install dependencies by running `$ pod install`
2. Replace the `clientId`, `appSecret` and `customerIdentifier` constants in [AppDelegate.m:41-43](https://github.com/saltedge/saltedge-ios/blob/master/Salt%20Edge%20API%20Demo/AppDelegate.m#L41-L43) with your Client ID and corresponding App secret
3. Run the app

*Note*: You can find your Client ID and App secret at your [profile](https://www.saltedge.com/clients/profile/settings) page.

## SEWebView

A small `UIWebView` replacement for using [Salt Edge Connect](https://docs.saltedge.com/guides/connect/) within your iOS app.

### Usage

* Import the class and delegate files into your view controller
* Add a `SEWebView` instance to your view controllers' view, also set a `stateDelegate` for the web view
* Implement the `SEWebViewDelegate` methods in delegates' class
* Load the connect page in the web view

**NOTE:** Do not use the `delegate` property on `SEWebView`, since an `SEWebView` acts like a proxy object. If your class does need to respond to the `UIWebView` delegate methods, just implement them and the `SEWebView` instance will forward those messages to its `stateDelegate`.

### Example

Import the class and delegate files into your view controller, also let your view controller conform to the `SEWebViewDelegate` protocol.

```objc
#import "SEWebView.h"
#import "SEWebViewDelegate.h"
// ... snip ...

@interface MyViewController() <SEWebViewDelegate>
// ... snip ...
```

Instantiate a `SEWebView` and add it to your controller:

```objc
SEWebView* connectWebView = [[SEWebView alloc] initWithFrame:self.view.frame stateDelegate:self];
```

Implement the `SEWebViewDelegate` methods in your controller:

```objc
// ... snip ...

- (void)webView:(SEWebView *)webView receivedCallbackWithResponse:(NSDictionary *)response
{
    NSString* loginSecret = response[SELoginDataKey][SELoginSecretKey];
    NSString* loginState  = response[SELoginDataKey][SELoginStateKey];
    // do something with the data...
}

- (void)webView:(SEWebView *)webView receivedCallbackWithError:(NSError *)error
{
  // handle the error...
}
```

Keep in mind that you can also implement the `UIWebView` delegate methods:

```objc
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  // the method will be called after SEWebView has finished processing it
}
```

Load the Salt Edge Connect URL into the web view and you're good to go:

```objc
[connectWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:connectURLString]]];
```

## SEAPIRequestManager

A class designed with convenience methods for interacting with and querying the Salt Edge API. Contains methods for fetching entities (logins, transactions, accounts, et al.), for requesting login tokens for connecting, reconnecting and refreshing logins via a `SEWebView`, and also for connecting logins via the REST API.

### Usage

Import the manager class and link your Client ID and App secret in the first place before using it.

### Example

```objc
#import "SEAPIRequestManager.h"

// ... snip ...
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SEAPIRequestManager linkClientId:@"example-client-id" appSecret:@"example-app-secret"];
    // ... snip ...
}
```

Use the manager to interact with the provided API:

```objc
- (void)requestConnectToken
{
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];

    [manager requestCreateTokenWithParameters:@{ @"country_code" : @"XO", @"provider_code" : @"paypal_xo", @"return_to" : @"http://example.com", @"customer_id" : @"example-customer-id" } success:^(NSDictionary* responseObject) {
        NSString* connectURL = responseObject[kDataKey][kConnectURLKey];
        // load the connect URL into the SEWebView...
    } failure:^(SEError* error) {
        // handle the error...
    }];
}
```

## Models

There are some provided models for serializing the objects received in the API responses. These represent the providers, logins, accounts, transactions, provider fields and their options. Whenever you request a resource that returns one of these types, they will always get serialized into Objective-C classes. (For instance, the `fetchFullTransactionsListForAccountId:loginSecret:success:failure` method has a `NSSet` containing `SETransaction` instances in it's success callback.)

Models contained within the components:

* `SEAccount`
* `SELogin`
* `SEError`
* `SEProvider`
* `SEProviderField`
* `SEProviderFieldOption`
* `SETransaction`

For a supplementary description of the models listed above that is not included in the sources' docs, feel free to visit the [API Reference](https://docs.saltedge.com/reference/).

## Utilities and categories

A few categories and utility classes are bundled within the components, and are used internally, but you could also use them if you find that necessary.

## Documentation

Documentation is available for all of the components. Use quick documentation (Alt+Click) to get a quick glance at the documentation for a method or a property.

## Running the demo

To run the demo app contained in here, you have to provide the demo with your client ID, app secret, and a customer identifier.
Set up the `clientId`, `appSecret` and `customerIdentifier` constants to your Client ID and corresponding App secret in [AppDelegate.m:41-43](https://github.com/saltedge/saltedge-ios/blob/master/Salt%20Edge%20API%20Demo/AppDelegate.m#L41-L43).

## Versioning

The current version of the SDK is [2.5.1](https://github.com/saltedge/saltedge-ios/releases/tag/v2.5.1), and is in compliance with the Salt Edge API's [current version](https://docs.saltedge.com/#version_management). Any backward-incompatible changes in the API will result in changes to the SDK.

## License

See the LICENSE file.

## References

1. [Salt Edge Connect Guide](https://docs.saltedge.com/guides/connect/)
2. [Salt Edge API Reference](https://docs.saltedge.com/reference/)
