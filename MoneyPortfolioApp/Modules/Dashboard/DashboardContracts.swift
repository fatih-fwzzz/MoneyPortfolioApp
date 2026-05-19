import Foundation

protocol DashboardView: AnyObject {
    func show(viewModel: DashboardViewModel)
    func show(errorMessage: String)
}

protocol DashboardPresenting {
    func viewDidLoad()
    func didTapAllocation(at index: Int)
}

protocol DashboardInteracting {
    func fetchPortfolio() throws -> Portfolio
}

protocol DashboardRouting {
    func showAllocationDetail(portfolio: Portfolio, selectedIndex: Int)
}

struct DashboardViewModel {
    struct AllocationItem {
        let category: String
        let percentageText: String
        let nominalText: String
        let hexColor: String
    }

    let totalBalanceText: String
    let percentageChangeText: String
    let allocations: [AllocationItem]
    let monthlyTrendMonths: [String]
    let monthlyTrendValues: [Double]
}

