import Foundation

nonisolated protocol PortfolioRepository {
    func fetchPortfolio() throws -> Portfolio
}

