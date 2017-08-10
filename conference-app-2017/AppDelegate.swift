import UIKit
import OctavKit
import SwiftDate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupUINavigation()
        setupRegion()
        setupOctavKit()
        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(ApplicationShortcut.handleShortcutItem(with: shortcutItem))
    }
}

extension AppDelegate {
    fileprivate func setupUINavigation() {
        UINavigationBar.appearance().barTintColor = UIColor.Builderscon.themeRed
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    fileprivate func setupRegion() {
        let region = Region(
            tz: TimeZone(identifier: "JST")!,
            cal: Calendar(identifier: .gregorian),
            loc: Locale.current
        )
        Date.setDefaultRegion(region)
    }

    fileprivate func setupOctavKit() {
        OctavKit.setup(conferenceId: Config.conferenceIdentifier)
        OctavKit.setLocale(Locale.current)
        updateLocalData()
    }

    private func updateLocalData() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
            ConferenceRespository().update()
            SessionRepository().update()
        }
    }
}
