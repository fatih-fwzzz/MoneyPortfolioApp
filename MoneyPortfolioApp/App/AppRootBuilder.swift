import UIKit

enum AppRootBuilder {
    static func buildRootViewController() -> UIViewController {
        return UINavigationController(rootViewController: DashboardBuilder.build())
    }
}

