import UIKit

enum TransactionHistoryBuilder {
    static func build(allocation: AssetAllocation) -> UIViewController {
        let interactor = TransactionHistoryInteractor(allocation: allocation)
        let presenter = TransactionHistoryPresenter(interactor: interactor)
        let viewController = TransactionHistoryViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}

