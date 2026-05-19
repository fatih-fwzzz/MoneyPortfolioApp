import UIKit

enum DashboardBuilder {
    static func build() -> UIViewController {
        let interactor = DashboardInteractor(repository: AppDependencies.shared.portfolioRepository)
        let router = DashboardRouter()
        let presenter = DashboardPresenter(interactor: interactor, router: router)
        let viewController = DashboardViewController(presenter: presenter)
        presenter.view = viewController
        router.viewController = viewController
        return viewController
    }
}

