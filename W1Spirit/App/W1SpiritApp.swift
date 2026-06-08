import AnalyticsKit
import SwiftUI

@main
struct WNSPRTApp: App {
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self) private var firebaseDelegate
    @StateObject private var store = SpiritStore()

    var body: some Scene {
        WindowGroup {
            AnalyticsRootFlow(
                configuration: analyticsConfiguration,
                requestReviewBeforeCheck: false
            ) {
                ContentView()
                    .environmentObject(store)
                    .preferredColorScheme(.dark)
            }
        }
    }

    private var analyticsConfiguration: AnalyticsConfiguration {
        AnalyticsConfiguration(
            serverDomain: "frogking.site",
            analyticsToken: "7b7436f1864afb5e3af729d0b10480e2434b0feb9cf567e854d57f61eeeb5da8",
            bundleID: "app.w1spirit.forestmoodtrails"
        )
    }
}
