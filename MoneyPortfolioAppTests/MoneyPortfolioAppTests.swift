//
//  MoneyPortfolioAppTests.swift
//  MoneyPortfolioAppTests
//
//  Created by FWZ on 19/05/26.
//

import XCTest
@testable import MoneyPortfolioApp

final class MoneyPortfolioAppTests: XCTestCase {
    func testPortfolioRepositoryMapsSectionsIntoDomainModel() throws {
        let dataSource = MockDataSource(
            sections: [
                TransactionSectionDTO(
                    type: "donutChart",
                    donutData: [
                        AllocationDTO(
                            label: "Tarik Tunai",
                            percentage: "55",
                            data: [
                                TransactionDTO(trxDate: "21/01/2023", nominal: 300_000),
                                TransactionDTO(trxDate: "20/01/2023", nominal: 200_000)
                            ]
                        ),
                        AllocationDTO(
                            label: "QRIS Payment",
                            percentage: "31",
                            data: [
                                TransactionDTO(trxDate: "21/01/2023", nominal: 100_000)
                            ]
                        )
                    ],
                    lineData: nil
                ),
                TransactionSectionDTO(
                    type: "lineChart",
                    donutData: nil,
                    lineData: LineChartDTO(month: [3, 5, 6, 4, 8, 10])
                )
            ]
        )

        let repository = PortfolioRepositoryImpl(dataSource: dataSource)
        let portfolio = try repository.fetchPortfolio()

        XCTAssertEqual(portfolio.allocations.count, 2)
        XCTAssertEqual(portfolio.totalBalance, 600_000, accuracy: 0.1)
        XCTAssertEqual(portfolio.allocations[1].category, "QRIS")
        XCTAssertEqual(portfolio.monthlyTrends.count, 6)
    }

    func testDashboardInteractorReturnsRepositoryPortfolio() throws {
        let expected = Portfolio(
            totalBalance: 1_000_000,
            percentageChange: 2.4,
            allocations: [],
            monthlyTrends: []
        )
        let interactor = DashboardInteractor(repository: MockRepository(result: expected))

        let portfolio = try interactor.fetchPortfolio()
        XCTAssertEqual(portfolio.totalBalance, expected.totalBalance)
        XCTAssertEqual(portfolio.percentageChange, expected.percentageChange)
    }

    func testAllocationAndTransactionInteractorsReturnInjectedModels() {
        let allocation = AssetAllocation(
            category: "Topup Gopay",
            percentage: 7.7,
            nominal: 175_000,
            hexColor: "#CDDC39",
            transactions: [
                Transaction(id: UUID(), title: "Topup Gopay", date: Date(), amount: 75_000),
                Transaction(id: UUID(), title: "Topup Gopay", date: Date(), amount: 100_000)
            ]
        )
        let portfolio = Portfolio(totalBalance: 175_000, percentageChange: 0, allocations: [allocation], monthlyTrends: [])

        let allocationInteractor = AllocationDetailInteractor(portfolio: portfolio)
        let historyInteractor = TransactionHistoryInteractor(allocation: allocation)

        XCTAssertEqual(allocationInteractor.getPortfolio().allocations.first?.category, "Topup Gopay")
        XCTAssertEqual(historyInteractor.getAllocation().transactions.count, 2)
    }
}

private struct MockDataSource: TransactionDataProviding {
    let sections: [TransactionSectionDTO]

    func loadSections() throws -> [TransactionSectionDTO] {
        sections
    }
}

private struct MockRepository: PortfolioRepository {
    let result: Portfolio

    func fetchPortfolio() throws -> Portfolio {
        result
    }
}
