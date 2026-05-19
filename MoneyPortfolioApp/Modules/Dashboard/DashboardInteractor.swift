import Foundation

final class DashboardInteractor: DashboardInteracting {
    private let repository: PortfolioRepository

    init(repository: PortfolioRepository) {
        self.repository = repository
    }

    func fetchPortfolio() throws -> Portfolio {
        try repository.fetchPortfolio()
    }
}

