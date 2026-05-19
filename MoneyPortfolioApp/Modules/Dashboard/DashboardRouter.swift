import UIKit

final class DashboardRouter: DashboardRouting {
    weak var viewController: UIViewController?

    func showAllocationDetail(portfolio: Portfolio, selectedIndex: Int) {
        let destination = AllocationDetailBuilder.build(portfolio: portfolio, selectedIndex: selectedIndex)
        viewController?.navigationController?.pushViewController(destination, animated: true)
    }
}

