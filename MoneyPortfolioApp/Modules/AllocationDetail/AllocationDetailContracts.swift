import Foundation

protocol AllocationDetailView: AnyObject {
    func show(viewModel: AllocationDetailViewModel)
}

protocol AllocationDetailPresenting {
    func viewDidLoad()
    func didTapAllocation(at index: Int)
}

protocol AllocationDetailInteracting {
    func getPortfolio() -> Portfolio
}

protocol AllocationDetailRouting {
    func showTransactionHistory(for allocation: AssetAllocation)
}

struct AllocationDetailViewModel {
    struct Item {
        let category: String
        let percentageText: String
        let nominalText: String
        let hexColor: String
    }

    let totalAllocationText: String
    let items: [Item]
    let selectedIndex: Int
}

