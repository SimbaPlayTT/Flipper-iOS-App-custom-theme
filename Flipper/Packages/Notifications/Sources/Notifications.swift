import UIKit

import FirebaseCore
import FirebaseMessaging

@MainActor
public class Notifications: NSObject, ObservableObject {
    public static let shared: Notifications = .init()

    let firmwareReleaseTopic = "flipper_update_firmware_release"

    public enum Error: Swift.Error {
        case notAllowed
    }

    public var isEnabled: Bool {
        get async {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            return settings.authorizationStatus == .authorized &&
                UIApplication.shared.isRegisteredForRemoteNotifications
        }
    }

    private override init() {
        super.init()
        setup()
    }

    private func setup() {
        // GoogleService-Info.plist is registered to the upstream bundle id.
        // Firebase hard-crashes at configure() if it doesn't match the
        // running app's bundle id, which it won't for rebranded builds —
        // skip it rather than take down the whole app on every launch.
        if Self.firebaseBundleIDMatches {
            FirebaseApp.configure()
            Messaging.messaging().delegate = self
        }

        UNUserNotificationCenter.current().delegate = self
    }

    private static var firebaseBundleIDMatches: Bool {
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path),
            let configuredBundleID = plist["BUNDLE_ID"] as? String
        else { return false }
        return configuredBundleID == Bundle.main.bundleIdentifier
    }

    public func enable() async throws {
        let center = UNUserNotificationCenter.current()
        var settings = await center.notificationSettings()

        guard settings.authorizationStatus != .denied else {
            throw Error.notAllowed
        }

        if settings.authorizationStatus == .notDetermined {
            try await requestAuthorization()
            settings = await center.notificationSettings()
        }

        guard settings.authorizationStatus == .authorized else {
            throw Error.notAllowed
        }

        UIApplication.shared.registerForRemoteNotifications()
    }

    func requestAuthorization() async throws {
        do {
            let center = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            try await center.requestAuthorization(options: options)
        } catch {
            throw Error.notAllowed
        }
    }

    public func disable() async {
        if Self.firebaseBundleIDMatches {
            do {
                let messaging = Messaging.messaging()
                if messaging.apnsToken != nil, messaging.fcmToken != nil {
                    try await messaging.deleteToken()
                }
            } catch {
                logger.error("delete token: \(error)")
            }
        }

        UIApplication.shared.unregisterForRemoteNotifications()
    }
}

extension Notifications: UNUserNotificationCenterDelegate {
}

extension Notifications: MessagingDelegate {
    public func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        #if DEBUG
        print("Firebase registration token: \(String(describing: fcmToken))")
        #endif

        if messaging.apnsToken != nil, fcmToken != nil {
            messaging.subscribe(toTopic: firmwareReleaseTopic)
        }

        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever
        // a new token is generated.
    }
}
