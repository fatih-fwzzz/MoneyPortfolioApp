import Foundation

nonisolated final class TransactionHistoryInteractor: TransactionHistoryInteracting {
    private let allocation: AssetAllocation

    init(allocation: AssetAllocation) {
        self.allocation = allocation
    }

    func getAllocation() -> AssetAllocation {
        allocation
    }
}

