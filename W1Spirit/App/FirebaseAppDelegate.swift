import FirebaseAnalytics
import FirebaseCore
import FirebaseMessaging
import UIKit
import UserNotifications

final class FirebaseAppDelegate: NSObject, UIApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate, @preconcurrency MessagingDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureFirebaseIfAvailable()
        UNUserNotificationCenter.current().delegate = self
        requestPushAuthorization(for: application)
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        Analytics.logEvent("apns_token_registered", parameters: nil)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Analytics.logEvent("apns_registration_failed", parameters: [
            "reason": error.localizedDescription
        ])
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Analytics.logEvent("fcm_token_refreshed", parameters: [
            "has_token": fcmToken == nil ? "false" : "true"
        ])
        #if DEBUG
        if let fcmToken {
            print("WN SPRT FCM token: \(fcmToken)")
        }
        #endif
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Analytics.logEvent("push_foreground_received", parameters: [
            "identifier": notification.request.identifier
        ])
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Analytics.logEvent("push_opened", parameters: [
            "identifier": response.notification.request.identifier,
            "action": response.actionIdentifier
        ])
        completionHandler()
    }

    private func configureFirebaseIfAvailable() {
        guard FirebaseApp.app() == nil else { return }
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            #if DEBUG
            print("WN SPRT Firebase is waiting for GoogleService-Info.plist.")
            #endif
            return
        }

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [
            "source": "swiftui_launch"
        ])
    }

    private func requestPushAuthorization(for application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                Analytics.logEvent("push_permission_result", parameters: [
                    "granted": granted ? "true" : "false",
                    "has_error": error == nil ? "false" : "true"
                ])
                guard granted else { return }
                application.registerForRemoteNotifications()
            }
        }
    }
}
