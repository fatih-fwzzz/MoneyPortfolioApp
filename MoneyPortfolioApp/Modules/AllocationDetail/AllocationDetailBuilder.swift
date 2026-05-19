import UIKit

enum AllocationDetailBuilder {
    static func build(portfolio: Portfolio, selectedIndex: Int) -> UIViewController {
        let interactor = AllocationDetailInteractor(portfolio: portfolio)
        let router = AllocationDetailRouter()
        let presenter = AllocationDetailPresenter(interactor: interactor, router: router, selectedIndex: selectedIndex)
        let viewController = AllocationDetailViewController(presenter: presenter)
        presenter.view = viewController
        router.viewController = viewController
        return viewController
    }
}

