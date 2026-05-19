import Foundation

protocol TransactionHistoryView: AnyObject {
    func show(viewModel: TransactionHistoryViewModel)
}

protocol TransactionHistoryPresenting {
    func viewDidLoad()
}

protocol TransactionHistoryInteracting {
    func getAllocation() -> AssetAllocation
}

struct TransactionHistoryViewModel {
    struct Item {
        let title: String
        let dateText: String
        let amountText: String
    }

    let categoryTitle: String
    let totalSpentText: String
    let items: [Item]
    let hexColor: String
}

