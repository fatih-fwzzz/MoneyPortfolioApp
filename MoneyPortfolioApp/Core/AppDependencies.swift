import Foundation

final class AppDependencies {
    static let shared = AppDependencies()

    let portfolioRepository: PortfolioRepository

    private init() {
        portfolioRepository = PortfolioRepositoryImpl(dataSource: TransactionDataLocalDataSource())
    }
}

