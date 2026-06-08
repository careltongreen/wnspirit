# AnalyticsKit

Reusable SwiftUI analytics launch package for iPhone apps.

Requires `iOS 16+`.

## What Is Included

- `AnalyticsConfiguration` for all server and launch settings.
- `AnalyticsLaunchPanel` for button-driven checks.
- `AnalyticsRootFlow` for root-level native-or-web routing.
- `AnalyticsBrowserScreen` for the destination experience.
- `AnalyticsRequestClient` for server communication.
- Apple Pay compatible `WKWebView` setup, assuming the loaded website supports Apple Pay on the web.
- On-demand file upload support for `input[type=file]`.
- Audio/session keepalive workarounds for game-like web runtimes on iPhone/iPad.

## Add To An App

```swift
dependencies: [
    .package(path: "../analytics-kit")
]
```

```swift
import AnalyticsKit
```

## Configure

```swift
let analyticsConfiguration = AnalyticsConfiguration(
    serverDomain: "frogking.site",
    analyticsToken: "7b7436f1864afb5e3af729d0b10480e2434b0feb9cf567e854d57f61eeeb5da8",
    bundleID: Bundle.main.bundleIdentifier ?? "app.w1spirit.forestmoodtrails"
)
```

Ready-made preset:

```swift
AnalyticsConfiguration.standardPreset
```

## Use The Launch Panel

```swift
AnalyticsLaunchPanel(
    configuration: .standardPreset
)
```

The launch panel reads the current language reactively from `@AppStorage("settings.language")`, sends the request, and opens the returned destination only when the response is enabled.

## Use As App Root

```swift
@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            AnalyticsRootFlow(
                configuration: .standardPreset,
                requestReviewBeforeCheck: false
            ) {
                RootTabView()
            }
        }
    }
}
```

Default root flow:

```text
native app -> short delay -> POST /api/v1/check -> keep native app or open returned destination
```

The delay is configured through `initialCheckDelay` in `AnalyticsConfiguration` and defaults to `0.45` seconds.

## Analytics Request

The package sends a `POST` request to:

```text
https://frogking.site/api/v1/check
```

Headers:

```text
Content-Type: application/json
Accept: application/json
Authorization: Bearer <analyticsToken>
X-Analytics-Token: <analyticsToken>
X-Bundle-ID: <bundleID>
X-Server-Domain: <serverDomain>
```

Body example:

```json
{
  "app_id": "app.w1spirit.forestmoodtrails",
  "bundle_id": "app.w1spirit.forestmoodtrails",
  "domain": "frogking.site",
  "key": "analytics-token"
}
```

## Backend Response

Supported disabled response:

```json
false
```

Supported enabled response with destination URL:

```json
{
  "result": true,
  "postback_url": "https://example.com/start"
}
```

The package appends:

```text
platform=ios
language=<preferredLanguage>
```

The response can also use `enabled` with `url`, `openURL`, `targetURL`, or supported legacy URL keys.

## Firebase

Firebase is not included. The module does not import `FirebaseCore`, does not import `FirebaseAnalytics`, and does not send `app_instance_id`.

## Apple Pay Notes

The browser screen can display Apple Pay flows when the website itself supports Apple Pay on the web. The web domain must use HTTPS, have a valid Apple Pay merchant setup, host the required merchant association file, and run the Apple Pay JavaScript flow correctly.

## File Upload Notes

File upload handling is on-demand. The package does not request file access up front. The system picker is presented only when the loaded web page opens a file upload control such as `input[type=file]`.

## Store Review Note

Use this package transparently. Do not use remote responses to hide, swap, or review-gate unrelated app functionality.
