## Salt Edge iOS

A handful of classes to help you interact with the Salt Edge API from your iOS app.

## Requirements

iOS 7+, ARC.

## Installation
### CocoaPods

Add the pod to your `Podfile`

```ruby
# ... snip ...

# To use Spectre API v3
pod 'SaltEdge-iOS', '~> 3.2.0'

# To use Spectre API v2
pod 'SaltEdge-iOS', '~> 2.6.0'

```

Install the pod

`$ pod install`

### Source

Clone this repository

`$ git clone git@github.com:saltedge/saltedge-ios.git`

Copy the `Classes` folder into your project.

## Connecting logins using the sample app

1. Install dependencies by running `$ pod install`
2. Replace the `clientId`, `appSecret` and `customerIdentifier` constants in [AppDelegate.m:43-45](https://github.com/saltedge/saltedge-ios/blob/master/Salt%20Edge%20API%20Demo/AppDelegate.m#L43-L45) with your Client ID and corresponding App secret
3. Run the app

*Note*: You can find your Client ID and App secret at your [secrets](https://www.saltedge.com/clients/profile/secrets) page.

## SEWebView

A small `UIWebView` replacement for using [Salt Edge Connect](https://docs.saltedge.com/guides/connect/) within your iOS app.

### Usage

#### Swift

You can use the SaltEdge iOS SDK in Swift projects as well. To do so, follow the installation instructions, and in addition to that, [create a bridging header](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html#//apple_ref/doc/uid/TP40014216-CH10-ID122) and import the classes you wish to use in Swift into that bridging header.

* Import the class and delegate files into your view controller (Objective-C only)
* Add a `SEWebView` instance to your view controllers' view, also set a `stateDelegate` for the web view
* Implement the `SEWebViewDelegate` methods in delegates' class
* Load the connect page in the web view
* Wait for `SEWebViewDelegate` callbacks and handle them

**NOTE:** Do not use the `delegate` property on `SEWebView`, since an `SEWebView` acts like a proxy object. If your class does need to respond to the `UIWebView` delegate methods, just implement them and the `SEWebView` instance will forward those messages to its `stateDelegate`.

### Example

#### Objective-C

Import the class and delegate files into your view controller, also let your view controller conform to the `SEWebViewDelegate` protocol.

```objc
#import "SEWebView.h"
#import "SEWebViewDelegate.h"
// ... snip ...

@interface MyViewController() <SEWebViewDelegate>
// ... snip ...
```

Instantiate a `SEWebView` and add it to the controller:

```objc
SEWebView* connectWebView = [[SEWebView alloc] initWithFrame:self.view.bounds stateDelegate:self];
[self.view addSubview:connectWebView];
```

Implement the `SEWebViewDelegate` methods in the controller:

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

#### Swift

Let your view controller conform to the `SEWebViewDelegate` protocol.

```swift
class MyViewController : UIViewController, SEWebViewDelegate {
  // ... snip ...
}
```

Instantiate a `SEWebView` and add it to the controller:

```swift
let connectWebView = SEWebView.init(frame: self.view.bounds, stateDelegate: self)
self.view.addSubview(connectWebView)
```

Implement the `SEWebViewDelegate` methods in the controller:

```swift
// ... snip ...

func webView(webView: SEWebView!, receivedCallbackWithResponse response: [NSObject : AnyObject]!) {
    if let secret = response["data"]?["secret"] as? String,
       let state  = response["data"]?["state"]  as? String {
            // do something with the data...
    }
}

func webView(webView: SEWebView!, receivedCallbackWithError error: NSError!) {
    // handle the error...
}
```

Keep in mind that you can also implement the `UIWebView` delegate methods:

```swift
func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    // the method will be called after SEWebView has finished processing it
}
```

Load the Salt Edge Connect URL into the web view and you're good to go:

```swift
if let url = NSURL.init(string: connectURLString) {
    self.webView.loadRequest(NSURLRequest.init(URL: url))
}
```

## SEAPIRequestManager

A class designed with convenience methods for interacting with and querying the Salt Edge API. Contains methods for fetching entities (logins, transactions, accounts, et al.), for requesting login tokens for connecting, reconnecting and refreshing logins via a `SEWebView`, and also for connecting logins via the REST API.

### Usage

Import the manager class and link your Client ID and App secret in the first place before using it.

### Example

#### Objective-C

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

    NSDictionary* params = @{ @"country_code" : @"XO", @"provider_code" : @"paypal_xo", @"return_to" : @"http://example.com", @"customer_id" : @"example-customer-id" };
    [manager requestCreateTokenWithParameters:params success:^(NSDictionary* responseObject) {
      if (responseObject[kDataKey] && responseObject[kDataKey][kConnectURLKey]) {
          NSString* connectURL = responseObject[kDataKey][kConnectURLKey];
          // load the connect URL into the SEWebView...
      }
    } failure:^(SEError* error) {
        // handle the error...
    }];
}
```

#### Swift

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    SEAPIRequestManager.linkClientId("example-client-id", appSecret: "example-app-secret")
    // ... snip ...
}
```

Use the manager to interact with the provided API:

```swift
func requestConnectToken() {
    let manager: SEAPIRequestManager = SEAPIRequestManager()

    let params = ["country_code" : "XO", "provider_code" : "paypal_xo", "return_to" : "http://example.com", "customer_id" : "customer_id_here"]
    manager.requestCreateTokenWithParameters(params, success: {
        response in
        if let urlString = response["data"]?["connect_url"] as? String {
            if let url = NSURL.init(string: urlString) {
              // load the connect URL into the SEWebView...
            }
        }
        }, failure: {
            error in
            // handle the error...
    })
}
```

## Models

There are some provided models for serializing the objects received in the API responses. These represent the providers, logins, accounts, transactions, provider fields and their options. Whenever you request a resource that returns one of these types, they will always get serialized into Objective-C classes. For instance, the `fetchFullTransactionsListForAccountId:loginSecret:success:failure` method has a `NSSet` containing `SETransaction` instances in it's success callback.

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
Set up the `clientId`, `appSecret` and `customerIdentifier` constants to your Client ID and corresponding App secret in [AppDelegate.m:43-45](https://github.com/saltedge/saltedge-ios/blob/master/Salt%20Edge%20API%20Demo/AppDelegate.m#L43-L45).

## Versioning

The current version of the SDK is [3.2.0](https://github.com/saltedge/saltedge-ios/releases/tag/v3.2.0), and is in compliance with the Salt Edge API's [current version](https://docs.saltedge.com/guides/versioning/). Any backward-incompatible changes in the API will result in changes to the SDK.

## Security

Starting with the [3.1.0](https://github.com/saltedge/saltedge-ios/releases/tag/v3.1.0) release, the SDK enables SSL pinning. That means that every API request that originates in `SEAPIRequestManager` will have SSL certificate validation. The current Salt Edge SSL certificate will expire on 1st of May 2018, meaning that it will be renewed in the first week of April 2018. Following the SSL certificate renewal, the SDK will be updated to use the new certificate for SSL pinning. As a result of that, usage of older versions of the SDK will not be possible since every request will fail because of the old SSL certificate. Salt Edge clients will be notified about this and there will be enough time in order to update the apps to the newer version of the SDK.

## License

See the LICENSE file.

## References

1. [Salt Edge Connect Guide](https://docs.saltedge.com/guides/connect/)
2. [Salt Edge API Reference](https://docs.saltedge.com/reference/)
