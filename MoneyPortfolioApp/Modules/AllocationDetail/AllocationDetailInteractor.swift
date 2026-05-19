import Foundation

final class AllocationDetailInteractor: AllocationDetailInteracting {
    private let portfolio: Portfolio

    init(portfolio: Portfolio) {
        self.portfolio = portfolio
    }

    func getPortfolio() -> Portfolio {
        portfolio
    }
}

