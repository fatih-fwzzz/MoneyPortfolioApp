import UIKit

final class AllocationDetailRouter: AllocationDetailRouting {
    weak var viewController: UIViewController?

    func showTransactionHistory(for allocation: AssetAllocation) {
        let destination = TransactionHistoryBuilder.build(allocation: allocation)
        viewController?.navigationController?.pushViewController(destination, animated: true)
    }
}

