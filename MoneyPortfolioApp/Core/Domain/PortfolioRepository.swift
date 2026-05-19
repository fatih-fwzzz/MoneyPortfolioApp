import Foundation

protocol PortfolioRepository {
    func fetchPortfolio() throws -> Portfolio
}

